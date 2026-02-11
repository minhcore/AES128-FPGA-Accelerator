#!/usr/bin/env python3
"""
Script giao tiếp UART với chip AES
Gửi key từ key.txt và data từ data.txt, nhận cipher từ chip và lưu vào cipher.txt
"""

import serial
import time
import sys

# Cấu hình UART
SERIAL_PORT = 'COM5'  # Thay đổi theo cổng COM của bạn (Windows: COM3, Linux: /dev/ttyUSB0)
BAUD_RATE = 115200             # Thay đổi theo baudrate của chip
TIMEOUT = 2                    # Timeout 2 giây

# Định nghĩa header và footer theo Verilog
KEY_HEADER = 0xBB
DATA_HEADER = 0xAA
FOOTER = 0x55

def calculate_checksum(header, data_bytes):
    """Tính checksum = XOR của header và tất cả data bytes"""
    checksum = header
    for byte in data_bytes:
        checksum ^= byte
    return checksum

def create_packet(header, data_bytes):
    """Tạo gói tin với format: Header + Data(16 bytes) + Checksum + Footer"""
    if len(data_bytes) != 16:
        raise ValueError(f"Data phải đúng 16 bytes, nhận được {len(data_bytes)} bytes")
    
    checksum = calculate_checksum(header, data_bytes)
    packet = bytes([header]) + data_bytes + bytes([checksum, FOOTER])
    return packet

def send_packet(ser, packet, packet_type="DATA"):
    """Gửi gói tin qua UART"""
    print(f"\n[{packet_type}] Gửi gói tin ({len(packet)} bytes):")
    print(f"  Header:   0x{packet[0]:02X}")
    print(f"  Data:     {' '.join(f'{b:02X}' for b in packet[1:17])}")
    print(f"  Checksum: 0x{packet[17]:02X}")
    print(f"  Footer:   0x{packet[18]:02X}")
    
    ser.write(packet)
    ser.flush()
    print(f"[{packet_type}] Đã gửi thành công!")

def receive_response(ser, expected_bytes=19, timeout=2):
    """Nhận phản hồi từ chip"""
    print(f"\n[RX] Đợi nhận {expected_bytes} bytes...")
    
    start_time = time.time()
    received_data = b''
    
    while len(received_data) < expected_bytes:
        if time.time() - start_time > timeout:
            print(f"[RX] Timeout! Chỉ nhận được {len(received_data)}/{expected_bytes} bytes")
            break
        
        if ser.in_waiting > 0:
            byte = ser.read(1)
            received_data += byte
            # print(f"  Nhận byte: 0x{byte[0]:02X}")
    
    if len(received_data) == expected_bytes:
        print(f"[RX] Nhận đủ {len(received_data)} bytes:")
        print(f"  Header:   0x{received_data[0]:02X}")
        print(f"  Data:     {' '.join(f'{b:02X}' for b in received_data[1:17])}")
        print(f"  Checksum: 0x{received_data[17]:02X}")
        print(f"  Footer:   0x{received_data[18]:02X}")
        
        # Kiểm tra checksum
        expected_checksum = calculate_checksum(received_data[0], received_data[1:17])
        if received_data[17] == expected_checksum and received_data[18] == FOOTER:
            print("[RX] ✓ Checksum và Footer hợp lệ!")
            return received_data[1:17]  # Trả về 16 bytes data
        else:
            print("[RX] ✗ Lỗi checksum hoặc footer!")
            return None
    
    return None

def main():
    print("=" * 60)
    print("  UART AES Communication Script")
    print("=" * 60)
    
    # Đọc key từ file key.txt
    try:
        with open('key.txt', 'r') as f:
            key_str = f.read().strip()
            if len(key_str) != 16:
                print(f"[ERROR] Key phải đúng 16 ký tự, nhận được {len(key_str)} ký tự")
                sys.exit(1)
            key_bytes = key_str.encode('ascii')
            print(f"\n[KEY] Đọc key từ key.txt: '{key_str}'")
    except FileNotFoundError:
        print("[ERROR] Không tìm thấy file key.txt!")
        sys.exit(1)
    
    # Đọc data từ file data.txt
    try:
        with open('data.txt', 'r') as f:
            data_str = f.read().strip()
            if len(data_str) != 16:
                print(f"[ERROR] Data phải đúng 16 ký tự, nhận được {len(data_str)} ký tự")
                sys.exit(1)
            data_bytes = data_str.encode('ascii')
            print(f"[DATA] Đọc data từ data.txt: '{data_str}'")
    except FileNotFoundError:
        print("[ERROR] Không tìm thấy file data.txt!")
        sys.exit(1)
    
    # Kết nối UART
    try:
        print(f"\n[UART] Kết nối tới {SERIAL_PORT} @ {BAUD_RATE} baud...")
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=TIMEOUT)
        time.sleep(0.5)  # Đợi port ổn định
        print("[UART] Kết nối thành công!")
        
        # Xóa buffer
        ser.reset_input_buffer()
        ser.reset_output_buffer()
        
        # Bước 1: Gửi KEY
        print("\n" + "=" * 60)
        print("BƯỚC 1: GỬI KEY")
        print("=" * 60)
        key_packet = create_packet(KEY_HEADER, key_bytes)
        send_packet(ser, key_packet, "KEY")
        time.sleep(0.1)  # Đợi chip xử lý
        
        # Bước 2: Gửi DATA
        print("\n" + "=" * 60)
        print("BƯỚC 2: GỬI DATA")
        print("=" * 60)
        data_packet = create_packet(DATA_HEADER, data_bytes)
        send_packet(ser, data_packet, "DATA")
        
        # Bước 3: Nhận CIPHER
        print("\n" + "=" * 60)
        print("BƯỚC 3: NHẬN CIPHER")
        print("=" * 60)
        cipher_bytes = receive_response(ser, expected_bytes=19, timeout=5)
        
        if cipher_bytes:
            # Lưu vào file cipher.txt
            cipher_hex = ''.join(f'{b:02X}' for b in cipher_bytes)
            with open('cipher.txt', 'w') as f:
                f.write(cipher_hex)
            print(f"\n[CIPHER] Đã lưu vào cipher.txt:")
            print(f"  Hex: {cipher_hex}")
            print(f"  ASCII: {cipher_bytes.hex()}")
            print("\n" + "=" * 60)
            print("✓ HOÀN THÀNH!")
            print("=" * 60)
        else:
            print("\n[ERROR] Không nhận được cipher từ chip!")
            print("=" * 60)
        
        ser.close()
        
    except serial.SerialException as e:
        print(f"[ERROR] Lỗi kết nối UART: {e}")
        print(f"  Kiểm tra lại cổng COM và driver!")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n\n[INFO] Đã hủy bởi người dùng")
        if 'ser' in locals() and ser.is_open:
            ser.close()
        sys.exit(0)

if __name__ == "__main__":
    main()