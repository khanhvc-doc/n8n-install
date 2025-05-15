from text_to_speech import TextToSpeech
import json

def test_text_to_speech():
    # Khởi tạo đối tượng TextToSpeech
    tts = TextToSpeech()
    
    # Dữ liệu test
    noi_dung ="""
        c nhau một cách nhanh chóng và dễ theo dõi.
    """
    test_data = [
        {
            "noi_dung": noi_dung,
            "ngon_ngu": "tiếng việt",
            "giong_doc": "nữ"
        }
        # ,{
        #     "noi_dung": "Chào buổi sáng, tôi là giọng đọc nam",
        #     "ngon_ngu": "tiếng việt",
        #     "giong_doc": "nam"
        # }
    ]
    
    # Thực hiện chuyển đổi cho từng bộ dữ liệu test
    for i, data in enumerate(test_data):
        print(f"\n--- Test #{i+1} ---")
        print(f"Nội dung: {data['noi_dung']}")
        print(f"Ngôn ngữ: {data['ngon_ngu']}")
        print(f"Giọng đọc: {data['giong_doc']}")
        
        # Gọi phương thức chuyển đổi
        result = tts.convert_text_to_speech(
            data['noi_dung'], 
            data['ngon_ngu'], 
            data['giong_doc']
        )
        
        # In kết quả
        if result['success']:
            print("Kết quả: Thành công")
            print(f"File path: {result['file_path']}")
            print(f"Ngôn ngữ đã sử dụng: {result['language']}")
            print(f"Giọng đọc đã sử dụng: {result['gender']}")
        else:
            print("Kết quả: Thất bại")
            print(f"Lỗi: {result['error']}")

if __name__ == "__main__":
    test_text_to_speech()