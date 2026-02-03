import serial
import time
import struct
import random

# Cấu hình UART (Check lại COM port trên máy cậu)
SERIAL_PORT = 'COM5' 
BAUD_RATE = 115200 # Hoặc tốc độ cậu đang set trong Verilog

def calculate_checksum(payload):
    chk = 0xAA # Bắt đầu với Header
    for byte in payload:
        chk ^= byte
    return chk

def send_packet(ser, is_key=False):
    header = 0xBB if is_key else 0xAA
    
    # Tạo 16 byte random
    payload = [random.randint(0, 255) for _ in range(16)]
    
    # Tính checksum: Header ^ Byte0 ^ ... ^ Byte15
    checksum = header
    for b in payload:
        checksum ^= b
        
    footer = 0x55
    
    # Đóng gói thành bytes
    # B: unsigned char (1 byte)
    # 16B: 16 bytes
    packet_format = '>B16BBB' # Big-endian
    packet_data = struct.pack(packet_format, header, *payload, checksum, footer)
    
    ser.write(packet_data)
    print(f"Sent {'KEY' if is_key else 'DATA'} packet. Checksum: {hex(checksum)}")

try:
    with serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=1) as ser:
        print(f"Connected to {SERIAL_PORT}")
        
        #Test 1: Gửi 10 gói Data chuẩn
        for i in range(10):
            send_packet(ser, is_key=False)
            time.sleep(0.5) # Delay để mắt cậu kịp nhìn LED nháy
        """
        #Test 2: Gửi 5 gói Key chuẩn
        for i in range(5):
            send_packet(ser, is_key=True)
            time.sleep(0.5)
        
        #Test 3: Gửi Gói Rác (Để check đèn đỏ error_flag)
        print("Sending BAD packet...")
        bad_packet = b'\xAA' + b'\x00'*16 + b'\xFF' + b'\x55' # Sai checksum
        ser.write(bad_packet)
        """
except serial.SerialException as e:
    print(f"Error opening serial port: {e}")