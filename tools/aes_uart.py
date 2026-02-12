#!/usr/bin/env python3
"""
Script test UART đơn giản - Gửi RAW và nhận RAW
"""

import serial
import time

SERIAL_PORT = 'COM5'
BAUD_RATE = 115200

# Gói tin KEY (19 bytes)
KEY_PACKET = bytes([
    0xBB,  # Header
    0x30, 0x31, 0x32, 0x33, 0x34, 0x35, 0x36, 0x37,  # "01234567"
    0x38, 0x39, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46,  # "89ABCDEF"
    0xBD,  # Checksum
    0x55   # Footer
])

# Gói tin DATA (19 bytes)
DATA_PACKET = bytes([
    0xAA,  # Header
    0x48, 0x65, 0x6C, 0x6C, 0x6F, 0x20, 0x57, 0x6F,  # "Hello Wo"
    0x72, 0x6C, 0x64, 0x2C, 0x20, 0x41, 0x45, 0x53,  # "rld, AES"
    0xD1,  # Checksum
    0x55   # Footer
])

def main():
    print("=" * 60)
    print("  UART RAW TEST - Manual Send/Receive")
    print("=" * 60)
    
    try:
        print(f"\n[UART] Mở {SERIAL_PORT} @ {BAUD_RATE}...")
        ser = serial.Serial(SERIAL_PORT, BAUD_RATE, timeout=5)
        time.sleep(0.5)
        print("[UART] ✓ Đã mở!")
        
        # Xóa buffer
        ser.reset_input_buffer()
        ser.reset_output_buffer()
        
        # ==========================================
        # BƯỚC 1: GỬI KEY
        # ==========================================
        print("\n" + "=" * 60)
        print("BƯỚC 1: GỬI KEY PACKET")
        print("=" * 60)
        print(f"Gửi: {' '.join(f'{b:02X}' for b in KEY_PACKET)}")
        
        ser.write(KEY_PACKET)
        ser.flush()
        print("✓ Đã gửi KEY!")
        
        # Đợi xử lý
        time.sleep(0.3)
        
        # Kiểm tra có data phản hồi không
        if ser.in_waiting > 0:
            junk = ser.read(ser.in_waiting)
            print(f"⚠ Nhận được {len(junk)} bytes sau KEY: {' '.join(f'{b:02X}' for b in junk)}")
        
        ser.reset_input_buffer()
        
        # ==========================================
        # BƯỚC 2: GỬI DATA
        # ==========================================
        print("\n" + "=" * 60)
        print("BƯỚC 2: GỬI DATA PACKET")
        print("=" * 60)
        print(f"Gửi: {' '.join(f'{b:02X}' for b in DATA_PACKET)}")
        
        ser.write(DATA_PACKET)
        ser.flush()
        print("✓ Đã gửi DATA!")
        
        # ==========================================
        # BƯỚC 3: POLLING LIÊN TỤC
        # ==========================================
        print("\n" + "=" * 60)
        print("BƯỚC 3: POLLING BUFFER")
        print("=" * 60)
        print("Đợi 5 giây và in buffer mỗi 100ms...")
        print("(Nhấn Ctrl+C để dừng sớm)")
        
        try:
            for i in range(50):  # 50 x 100ms = 5 giây
                time.sleep(0.1)
                
                if ser.in_waiting > 0:
                    # Có data!
                    print(f"\n[+{i*100:4d}ms] ✓ PHÁT HIỆN {ser.in_waiting} BYTES!")
                    
                    # Đợi thêm chút để nhận hết
                    time.sleep(0.2)
                    
                    # Đọc tất cả
                    data = ser.read(ser.in_waiting)
                    print(f"\nNhận được {len(data)} bytes:")
                    print(f"HEX: {' '.join(f'{b:02X}' for b in data)}")
                    
                    # Nếu đủ 16 bytes - đó là cipher!
                    if len(data) >= 16:
                        print(f"\n✓✓✓ CIPHER (16 bytes đầu): {' '.join(f'{data[i]:02X}' for i in range(16))}")
                        
                        # Lưu file
                        with open('cipher_received.txt', 'w') as f:
                            f.write(''.join(f'{data[i]:02X}' for i in range(min(16, len(data)))))
                        print("✓ Đã lưu vào cipher_received.txt")
                    
                    break
                else:
                    # In dấu chấm mỗi 500ms
                    if i % 5 == 0:
                        print(f"[+{i*100:4d}ms] Buffer: 0", end="\r")
            else:
                print("\n\n✗ Timeout 5 giây - KHÔNG nhận được data!")
        
        except KeyboardInterrupt:
            print("\n\n[INFO] Dừng bởi người dùng")
            if ser.in_waiting > 0:
                data = ser.read(ser.in_waiting)
                print(f"Buffer còn {len(data)} bytes: {' '.join(f'{b:02X}' for b in data)}")
        
        print("\n" + "=" * 60)
        ser.close()
        print("Đã đóng cổng COM")
        
    except serial.SerialException as e:
        print(f"\n[ERROR] Lỗi UART: {e}")
        
    except Exception as e:
        print(f"\n[ERROR] {e}")
        import traceback
        traceback.print_exc()

if __name__ == "__main__":
    main()