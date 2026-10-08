.PHONY: install generate build check serve clean deploy rollback

install:
	pip3 install -r requirements.txt

generate:
	python3 scripts/generate_results.py

build: generate
	sphinx-build -b html docs _build/html

check: generate
	sphinx-build -b html -W --keep-going docs _build/html

serve:
	sphinx-autobuild docs _build/html --port 8000

clean:
	rm -rf _build docs/_static/plot.png docs/_static/metrics.json docs/_static/t1_chart.png

deploy:
	bash scripts/deploy.sh _build/html/

rollback:
	bash scripts/rollback.sh