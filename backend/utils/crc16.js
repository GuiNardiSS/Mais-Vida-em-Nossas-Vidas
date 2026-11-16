/**
 * CRC16/CCITT-FALSE (poly 0x1021, init 0xFFFF), usado no BR Code (PIX EMV).
 * Check value conhecido: crc16('123456789') === '29B1'.
 */
export function crc16(payload) {
  let crc = 0xffff;

  for (let index = 0; index < payload.length; index += 1) {
    crc ^= payload.charCodeAt(index) << 8;
    for (let bit = 0; bit < 8; bit += 1) {
      crc = crc & 0x8000 ? ((crc << 1) ^ 0x1021) & 0xffff : (crc << 1) & 0xffff;
    }
  }

  return crc.toString(16).toUpperCase().padStart(4, '0');
}

export default crc16;
