import sys, traceback
try:
    import room_booking_system.settings
except Exception:
    for tb in traceback.extract_tb(sys.exc_info()[2]):
        print(f'File: {tb.filename}, Line: {tb.lineno}')
