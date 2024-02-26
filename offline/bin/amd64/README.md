```bash
sudo -v ; curl https://gosspublic.alicdn.com/ossutil/install.sh | sudo bash
ossutil config
http://oss-cn-hangzhou.aliyuncs.com
oss-cn-hangzhou-internal.aliyuncs.com
oss-accelerate.aliyuncs.com
ossutil cp examplefile.txt oss://jefftommy/software/v1.29.2/
#上传文件夹及文件夹内的文件
ossutil cp -r localfolder/ oss://jefftommy/software/v1.29.2/
```