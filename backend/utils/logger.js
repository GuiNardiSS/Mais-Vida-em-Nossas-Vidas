/**
 * Logger estruturado minimalista (uma linha JSON por evento), sem dependências.
 * Em NODE_ENV=test o nível padrão é "silent" para não poluir a saída do Jest.
 */
const LEVELS = {
  debug: 10,
  info: 20,
  warn: 30,
  error: 40,
  silent: 100,
};

const DEFAULT_LEVEL =
  process.env.LOG_LEVEL || (process.env.NODE_ENV === 'test' ? 'silent' : 'info');

const serializeError = (error) => ({
  name: error?.name,
  message: error?.message,
  stack: error?.stack,
});

export function createLogger({ level = DEFAULT_LEVEL, base = {} } = {}) {
  let currentLevelName = LEVELS[level] !== undefined ? level : 'info';
  let currentLevel = LEVELS[currentLevelName];

  const write = (name, fields) => {
    if (LEVELS[name] < currentLevel) return;

    const entry = {
      level: name,
      time: new Date().toISOString(),
      ...base,
      ...fields,
    };

    if (entry.err instanceof Error) {
      entry.err = serializeError(entry.err);
    }

    const line = JSON.stringify(entry);
    if (name === 'error' || name === 'warn') {
      process.stderr.write(`${line}\n`);
    } else {
      process.stdout.write(`${line}\n`);
    }
  };

  return {
    debug: (message, fields = {}) => write('debug', { msg: message, ...fields }),
    info: (message, fields = {}) => write('info', { msg: message, ...fields }),
    warn: (message, fields = {}) => write('warn', { msg: message, ...fields }),
    error: (message, fields = {}) => write('error', { msg: message, ...fields }),
    child: (fields) =>
      createLogger({ level: currentLevelName, base: { ...base, ...fields } }),
    setLevel: (nextLevel) => {
      if (LEVELS[nextLevel] === undefined) return;
      currentLevelName = nextLevel;
      currentLevel = LEVELS[nextLevel];
    },
    level: () => currentLevel,
  };
}

export const logger = createLogger();

export default logger;
