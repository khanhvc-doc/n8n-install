1. Thực hiện ở bài cài n8n docker HTTP trước, nếu chưa cài n8n thì thực hiện
curl -L https://tinyurl.com/2y8sc6au | sh



2. thực hiện dòng lệnh dưới

-  Sửa nội dung file `.env`, phần domain cho đúng với domain của mình, có thể sửa trực tiếp hoặc dùng lệnh dưới

sudo sed -i 's/^MY_DOMAIN_NAME=.*/MY_DOMAIN_NAME=hansollvina.com/' .env
sudo sed -i 's/^MY_SUBDOMAIN=.*/MY_SUBDOMAIN=n8n/' .env
sudo sed -i 's/^EXTERNAL_IP=.*/EXTERNAL_IP=https:\/\/n8n.hansollvina.com/' .env

- Chạy lệnh dưới thể thực hiện cài chuyển từ http sang HTTPS
curl -L https://tinyurl.com/245nezt2 | sh

