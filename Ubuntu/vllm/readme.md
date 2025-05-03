1. kiểm tra nvidia
nvidia-smi
nếu chưa cài thì phải cài, và khởi động lại server

2. Cài đặt môi trường Python (khuyên dùng virtualenv)
sudo apt update
sudo apt install python3-venv python3-pip -y

# Tạo môi trường ảo
python3 -m venv vllm-env
source vllm-env/bin/activate

3. Cài vllm
sudo apt install build-essential -y
pip install vllm


4. Cài & token: https://huggingface.co/
pip install huggingface_hub
huggingface-cli login

vllm serve Qwen/Qwen2.5-7B-Instruct

vllm serve Qwen/Qwen2.5-7B-Instruct