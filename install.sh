

#git clone https://github.com/boto/boto3.git
cd boto3
virtualenv venv
. venv/bin/activate
python -m pip install -r requirements.txt
python -m pip install -e .
 python -m pip install boto3
cd ..
python -m pip install boto3
python rook.py --check-id