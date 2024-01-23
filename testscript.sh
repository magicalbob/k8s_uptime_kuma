#cd /opt/pwd
pip install -r requirements.txt
pip install uptime_kuma_api
~/.local/bin/coverage run -m unittest discover -v -s python -p '*_test.py'
~/.local/bin/coverage xml
rm -rf __pycache__
