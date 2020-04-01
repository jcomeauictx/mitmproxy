shell: venv/bin/activate
	bash --rcfile $< -i
start: venv/bin/activate
	bash --rcfile $< mitmdump \
	 --flow-detail 3 \
	 --set block_global=false \
	 &
env:
	env
venv/bin/activate: dev.sh
	./$< || echo 'Must install python3-virtualenv (RedHat)' \
	 ' or python3-venv (Debian)' >&2; false
