#!/usr/bin/env python3
import serial
import time

PORT = 'COM5'
BAUD = 115200

def make_packet(header, payload):
    """Create packet: [Header][16-byte payload][Checksum][Footer]"""
    if len(payload) != 16:
        raise ValueError(f"Payload must be 16 bytes, got {len(payload)}")
    
    cs = header
    for b in payload:
        cs ^= b
    
    return bytes([header]) + payload + bytes([cs, 0x55])

def read_hex_file(filename):
    """Read hex file, one 16-byte block per line"""
    blocks = []
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if line and len(line) == 32:
                blocks.append(bytes.fromhex(line))
    return blocks

def test():
    key = read_hex_file('key.txt')[0]
    data_list = read_hex_file('data.txt')
    
    with serial.Serial(PORT, BAUD, timeout=2) as s:
        s.reset_input_buffer()
        
        # Send KEY packet
        key_pkt = make_packet(0xBB, key)
        s.write(key_pkt)
        time.sleep(0.1)
        s.reset_input_buffer()
        
        print(f"KEY: {key.hex().upper()}\n")
        
        # Send DATA packets
        for i, data in enumerate(data_list, 1):
            data_pkt = make_packet(0xAA, data)
            s.write(data_pkt)
            time.sleep(0.3)
            
            rx = s.read(16)
            
            print(f"DATA {i}: {data.hex().upper()}")
            if len(rx) == 16:
                print(f"CIPHER {i}: {rx.hex().upper()}\n")
            else:
                print(f"CIPHER {i}: ERROR - got {len(rx)} bytes\n")
            
            s.reset_input_buffer()

if __name__ == "__main__":
    test()