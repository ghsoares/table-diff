import moment from "moment";
import { existsSync, mkdirSync, readFile, readFileSync } from "node:fs";
import path, { dirname } from "node:path";
import { createInterface } from "node:readline";
import XLSX from "xlsx-js-style";

const LINE_UNMODIFIED = 0;
const LINE_ADDED = 1;
const LINE_REMOVED = 2;
const LINE_MODIFIED = 3;

const RESULT_MODE_INLINE = 'INLINE';
const RESULT_MODE_SIDE = 'SIDE';

const mapSheet = (sheetLines, keys = [], remap = [], compareColumns = null) => {
	let header = sheetLines
		.splice(0, 1)[0]
		.map(h => h.trim())
		.map((h, i) => ({
			name: h,
			idx: i
		}));
	const hasKeys = keys.length > 0;
	if (!hasKeys) keys = ['__index__'];

	if (compareColumns != null) {
		header = header.filter(h => compareColumns.indexOf(h.name) != -1);
	}

	const lines = sheetLines.map((line, i) => {
		const obj = {};
		line.__i = i;
		header.forEach(h => {
			h.idx = h.idx;
			obj[h.name] = String(line[h.idx]).trim();
		});

		remap.forEach(r => {
			const { column, type } = r;
			let val = obj[column];
			switch (type) {
				case "DATE": {
					if (val !== null && val !== '?' && val !== 'null') {
						const { from, to } = r;
						const d = moment(val, from);
						if (!d.isValid()) {
							val = `[invalid date] ${val} - ${d}`;
						} else {
							val = `${val} - ${d.format(to)}`;
						}
					}
				} break;
				case "CHECK_NULL": {
					if (val === '?') val = 'null';
				} break;
			}
			obj[column] = val;
		});

		obj.__index__ = i;
		const index = keys.map(k => ('' + obj[k]));
		obj.__index__ = index;

		return obj;
	});

	const mappedKeyLenghts = keys.map((k, i) => {
		let maxLen = 0;
		lines.forEach(l => {
			let kl = l.__index__[i].length;
			maxLen = Math.max(maxLen, kl);
		});
		return maxLen;
	});

	return {
		lines,
		header,
		keyLengths: mappedKeyLenghts
	};
};

const indexLines = (lines, keys = [], keyLengths = []) => {
	keys.forEach((k, i) => {
		lines.forEach(l => {
			l.__index__[i] = l.__index__[i].padStart(keyLengths[i]);
		});
	});

	lines.forEach(l => {
		l.__index__ = l.__index__.join(';');
	});

	lines.sort((a, b) => {
		if (a.__index__ < b.__index__) return -1;
		if (a.__index__ > b.__index__) return 1;
		return 0;
	});
};

const mapFiles = ({
	beforeFile, afterFile,
	remapBefore, remapAfter,
	compareColumns,
	keys
}) => {
	const beforeBuf = readFileSync(beforeFile, { encoding: 'utf-8' });
	const afterBuf = readFileSync(afterFile, { encoding: 'utf-8' });

	const beforeSheet = XLSX.read(beforeBuf, { type: 'string' });
	const afterSheet = XLSX.read(afterBuf, { type: 'string' });

	const beforeJson = XLSX.utils.sheet_to_json(beforeSheet.Sheets[beforeSheet.SheetNames[0]], {header: 1});
	const afterJson = XLSX.utils.sheet_to_json(afterSheet.Sheets[afterSheet.SheetNames[0]], {header: 1});

	const before = mapSheet(beforeJson, keys, remapBefore, compareColumns);
	const after = mapSheet(afterJson, keys, remapAfter, compareColumns);

	const keyLengths = keys.map((k, i) => Math.max(before.keyLengths[i], after.keyLengths[i]));

	indexLines(before.lines, keys, keyLengths);
	indexLines(after.lines, keys, keyLengths);

	return [before.lines, after.lines, before.header];
};

const compareEntries = (left, right, header, ignoreFields = []) => {
	const leftLen = left.length;
	const rightLen = right.length;

	const lines = [];

	let leftPointer = 0, rightPointer = 0;
	while (leftPointer < leftLen || rightPointer < rightLen) {
		if (leftPointer == leftLen) {
			lines.push([LINE_ADDED, right[rightPointer].__index__, right[rightPointer]]);
			rightPointer++;
		} else if (rightPointer == rightLen) {
			lines.push([LINE_REMOVED, left[leftPointer].__index__, left[leftPointer]]);
			leftPointer++;
		} else {
			const l = left[leftPointer];
			const r = right[rightPointer];

			if (r.__index__ > l.__index__) {
				lines.push([LINE_REMOVED, l.__index__, l]);
				leftPointer++;
			} else if (r.__index__ < l.__index__) {
				lines.push([LINE_ADDED, r.__index__, r]);
				rightPointer++;
			} else {
				const modifiedValues = [];
				header.forEach(h => {
					const l_val = l[h.name] ?? '';
					const r_val = r[h.name] ?? '';
					if (ignoreFields.indexOf(h.name) == -1 && l_val != r_val) modifiedValues.push(h.name);
				});
				if (!modifiedValues.length) lines.push([LINE_UNMODIFIED, l.__index__, l]);
				else lines.push([LINE_MODIFIED, l.__index__, l, r, modifiedValues]);
				leftPointer++;
				rightPointer++;
			}
		}
	}

	return lines;
};

const generateResultSheet = (compared, header, beforeEnv = "PFS", afterEnv = "TC2", settings = {}) => {
	const {
		resultMode = RESULT_MODE_INLINE,
		resultGroup = false,
		includeUnmodified = false,
		lineUnmodifiedStyle = {
			fill: { fgColor: { rgb: "E2E4E6" } }
		},
		lineAddedStyle = {
			fill: { fgColor: { rgb: "61FFAC" } }
		},
		lineRemovedStyle = {
			fill: { fgColor: { rgb: "FD919B" } }
		},
		lineModifiedBeforeStyle = {
			fill: { fgColor: { rgb: "FFE269" } }
		},
		lineModifiedAfterStyle = {
			fill: { fgColor: { rgb: "92CDDC" } }
		},
		lineModifiedFieldStyle = {
			fill: { fgColor: { rgb: "B1A0C7" } }
		},
		sideSpacing = 0,
		includeCaptions = true,
		captionsSpacing = 1,
		includeOperation = true,
		operationSpacing = 1,
		rowSpacing = 0
	} = settings;

	if (resultGroup) {
		compared.sort((a, b) => {
			if (a[0] < b[0] || a[1] < b[1]) return -1;
			if (a[0] > b[0] || a[1] > b[1]) return 1;
			return 0;
		});
	}

	const wb = XLSX.utils.book_new();
	const data = [];
	let dw = 0, dh = 0;

	const setCells = (x, y, cells) => {
		if (cells.length === 0) return;
		if (cells[0].length === 0) return;

		const h = cells.length;
		const w = cells[0].length;

		if (x + w > dw) {
			for (let i = 0; i < dh; i++) {
				const row = data[i];
				row.length = x + w;
			}
			dw = x + w;
		}
		if (y + h > dh) {
			for (let i = dh; i < y + h; i++) {
				const row = [];
				row.length = dw;
				data.push(row);
			}
			dh = y + h;
		}

		for (let j = y; j < y + h; j++) {
			for (let i = x; i < x + w; i++) {
				data[j][i] = cells[j - y][i - x];
			}
		}
	};

	// Set header
	setCells(0, 0, [header.map(s => s.name)]);
	let currentSpacing = header.length;
	if (resultMode === RESULT_MODE_SIDE) {
		setCells(header.length + sideSpacing, 0, [header.map(s => s.name)]);
		currentSpacing = header.length * 2 + sideSpacing;
	}

	let currentOperationSpacing = currentSpacing + operationSpacing;
	if (includeOperation) {
		setCells(currentOperationSpacing, 0, [['Operação']]);
		currentSpacing += 1 + operationSpacing;
	}

	const operationCells = {
		unmodified: {
			v: 'Sem mudanças',
			t: 's',
			s: lineUnmodifiedStyle
		},
		created: {
			v: `Criado em ${afterEnv}`,
			t: 's',
			s: lineAddedStyle
		},
		removed: {
			v: `Removido de ${afterEnv}`,
			t: 's',
			s: lineRemovedStyle
		},
		modifiedBefore: {
			v: `Modificado (registro em ${beforeEnv})`,
			t: 's',
			s: lineModifiedBeforeStyle
		},
		modifiedAfter: {
			v: `Modificado (registro em ${afterEnv})`,
			t: 's',
			s: lineModifiedAfterStyle
		},
		modified: {
			v: `Modificado`,
			t: 's',
			s: lineModifiedAfterStyle
		},
		valueModified: {
			v: `Valor modificado em ${afterEnv}`,
			t: 's',
			s: lineModifiedFieldStyle
		}
	};

	if (includeCaptions) {
		const captionRows = [
			['LEGENDA']
		];
		if (includeUnmodified) {
			captionRows.push([operationCells.unmodified]);
		}
		captionRows.push(
			[operationCells.created],
			[operationCells.removed],
			[operationCells.modifiedBefore],
			[operationCells.modifiedAfter],
			[operationCells.valueModified]
		);
		setCells(currentSpacing + captionsSpacing, 0, captionRows);
	}

	let y = 1;
	compared.forEach(line => {
		switch (line[0]) {
			case LINE_UNMODIFIED: {
				if (includeUnmodified) {
					const row = header.map(s => ({ v: line[2][s.name], t: 's', s: lineUnmodifiedStyle }));
					setCells(0, y, [row]);
					if (resultMode === RESULT_MODE_SIDE) {
						setCells(header.length + sideSpacing, y, [row]);
					}
					if (includeOperation) {
						setCells(currentOperationSpacing, y, [[operationCells.unmodified]]);
					}
					y += 1 + rowSpacing;
				}
			} break;
			case LINE_ADDED: {
				const row = header.map(s => ({ v: line[2][s.name], t: 's', s: lineAddedStyle }));
				if (resultMode === RESULT_MODE_SIDE) {
					setCells(header.length + sideSpacing, y, [row]);
				} else {
					setCells(0, y, [row]);
				}
				if (includeOperation) {
					setCells(currentOperationSpacing, y, [[operationCells.created]]);
				}
				y += 1 + rowSpacing;
			} break;
			case LINE_REMOVED: {
				const row = header.map(s => ({ v: line[2][s.name], t: 's', s: lineRemovedStyle }));
				setCells(0, y, [row]);
				if (includeOperation) {
					setCells(currentOperationSpacing, y, [[operationCells.removed]]);
				}
				y += 1 + rowSpacing;
			} break;
			case LINE_MODIFIED: {
				const leftRow = header.map(s => ({ v: line[2][s.name], t: 's', s: lineModifiedBeforeStyle }));
				const rightRow = header.map(s => ({
					v: line[3][s.name], t: 's', s: line[4].indexOf(s.name) == -1 ? lineModifiedAfterStyle : lineModifiedFieldStyle
				}));

				setCells(0, y, [leftRow]);
				if (resultMode === RESULT_MODE_SIDE) {
					setCells(header.length + sideSpacing, y, [rightRow]);
					if (includeOperation) {
						setCells(currentOperationSpacing, y, [[operationCells.modified]]);
					}
				} else {
					setCells(0, y + 1, [rightRow]);
					if (includeOperation) {
						setCells(currentOperationSpacing, y, [[operationCells.modifiedBefore]]);
						setCells(currentOperationSpacing, y + 1, [[operationCells.modifiedAfter]]);
					}
					y += 1;
				}
				
				y += 1 + rowSpacing;
			} break;
		}
	});

	const ws = XLSX.utils.aoa_to_sheet(data);
	XLSX.utils.book_append_sheet(wb, ws, "Table difference");

	return wb;
};

const compareFiles = ({
	beforeFile, afterFile,
	remapBefore, remapAfter,
	beforeEnvironment, afterEnvironment,
	compareColumns,
	ignoreFields,
	keys, outputFile
}) => {
	const [before, after, header] = mapFiles({
		beforeFile, afterFile,
		remapBefore, remapAfter,
		compareColumns,
		keys
	});
	const compared = compareEntries(before, after, header, ignoreFields);
	const sheet = generateResultSheet(compared, header, beforeEnvironment, afterEnvironment);
	if (!existsSync(dirname(outputFile))) mkdirSync(dirname(outputFile), { recursive: true });
	XLSX.writeFile(sheet, `${outputFile}.xlsx`);
};

const rl = createInterface({
	input: process.stdin,
	output: process.stdout,
});

const query = `Escolha uma opção de comparação de tabelas:
0 - Usar Configuração Customizada;
1 - Comparar Grupos de Estruturas;
2 - Comparar Mapeamentos de Estruturas;
3 - Comparar Parâmetros de Entrada;
Outro - Sair\n`;

rl.questionAsync = function (query) {
	const self = this;
	return new Promise(resolve => {
		self.question(query, resolve);
	});
};

const setExtension = (pathStr, ext) => {
	return path.format({
		...path.parse(pathStr),
		base: '',
		ext
	})
}

const readConfig = (basePath, configPath) => {
	const configFilename = path.resolve(basePath, setExtension(configPath, 'json'));
	const configBasePath = path.dirname(configFilename);
	const data = readFileSync(configFilename, { encoding: 'utf-8' });
	const config = JSON.parse(data);
	const settings = [];

	config.forEach(conf => {
		if (conf.disabled) return;
		if (conf.configPath) {
			const innerConfig = readConfig(configBasePath, conf.configPath);
			settings.push(...innerConfig);
		} else {
			settings.push(conf);
		}
	});

	return settings;
};

while (true) {
	const choise = await rl.questionAsync(query);

	let configPath = null;
	switch (choise.trim()) {
		case '0': configPath = await rl.questionAsync('Insira o nome da configuração JSON a ser utilizada (relativo á pasta de execução):\n'); break;
		case '1': configPath = 'config/structure_group_compare'; break;
		case '2': configPath = 'config/structure_mapping_compare'; break;
		case '3': configPath = 'config/structure_input_mapping_compare'; break;
	}

	if (configPath != null) {
		const config = readConfig(process.cwd(), configPath);

		config.forEach(conf => {
			console.log(`Executando '${conf.name}'...`);
			compareFiles(conf);
			console.log(`Executado '${conf.name}' com sucesso.`);
		});
	} else break;
}

rl.close();
console.log("Saindo...");