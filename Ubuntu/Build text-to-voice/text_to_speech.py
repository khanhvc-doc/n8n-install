# text_to_speech.py
from gtts import gTTS
import os
import json
import uuid
import base64
from flask import Flask, request, jsonify

class TextToSpeech:
    def __init__(self):
        self.supported_languages = {
            "tiếng việt": "vi",
            "vietnamese": "vi",
            "english": "en",
            "tiếng anh": "en"
        }
        self.output_dir = "audio_files"
        
        # Tạo thư mục đầu ra nếu nó chưa tồn tại
        if not os.path.exists(self.output_dir):
            os.makedirs(self.output_dir)
    
    def generate_filename(self, extension="mp3", format_string="%Y_%m_%d-%H_%M_%S"):
        from datetime import datetime
        
        current_time = datetime.now()
        filename = f"{current_time.strftime(format_string)}.{extension}"
        return filename
    
    def convert_text_to_speech(self, noi_dung, ngon_ngu, giong_doc):
        """
        Chuyển đổi text thành giọng nói
        
        Args:
            noi_dung (str): Nội dung văn bản cần chuyển đổi
            ngon_ngu (str): Ngôn ngữ của văn bản (ví dụ: "tiếng việt")
            giong_doc (str): Giọng đọc - "nam" hoặc "nữ"
            
        Returns:
            dict: Kết quả bao gồm đường dẫn file âm thanh và dữ liệu base64
        """
        try:
            # Kiểm tra và xử lý ngôn ngữ
            ngon_ngu = ngon_ngu.lower().strip()
            lang_code = self.supported_languages.get(ngon_ngu, "vi")  # Mặc định là tiếng Việt
            
            # Xử lý giọng đọc
            # Lưu ý: gTTS không hỗ trợ trực tiếp việc chọn giọng nam/nữ
            # Chúng ta lưu thông tin này cho mục đích ghi nhận
            gender = "female" if giong_doc.lower() in ["nữ", "nu", "female"] else "male"
            
            # Tạo tên file ngẫu nhiên
            filename = self.generate_filename()
            filepath = os.path.join(self.output_dir, filename)
            
            # Tạo đối tượng gTTS và lưu file
            tts = gTTS(text=noi_dung, lang=lang_code, slow=False)
            tts.save(filepath)
            
            # Đọc file dưới dạng base64 để trả về
            with open(filepath, "rb") as audio_file:
                audio_data = base64.b64encode(audio_file.read()).decode('utf-8')
            
            return {
                "success": True,
                "file_path": filepath,
                "audio_data": audio_data,
                "language": lang_code,
                "gender": gender
            }
        
        except Exception as e:
            return {
                "success": False,
                "error": str(e)
            }

# Khởi tạo Flask API
app = Flask(__name__)
tts_engine = TextToSpeech()

@app.route('/api/text-to-speech', methods=['POST'])
def api_text_to_speech():
    # Nhận dữ liệu từ request
    data = request.get_json()
    
    # Kiểm tra và lấy các trường cần thiết
    if not data or 'noi_dung' not in data:
        return jsonify({"success": False, "error": "Thiếu trường 'noi_dung' trong dữ liệu"})
    
    noi_dung = data.get('noi_dung')
    ngon_ngu = data.get('ngon_ngu', 'tiếng việt')
    giong_doc = data.get('giong_doc', 'nữ')
    
    # Chuyển đổi và trả về kết quả
    result = tts_engine.convert_text_to_speech(noi_dung, ngon_ngu, giong_doc)
    return jsonify(result)

# Mã khởi chạy ứng dụng
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=5000, debug=True)


# curl -X POST http://<your-server-ip>:5000/api/text-to-speech \
# -H "Content-Type: application/json" \
# -d '{"noi_dung": "Xin chào, đây là giọng nói tự nhiên!", "ngon_ngu": "tiếng việt", "giong_doc": "nữ"}'