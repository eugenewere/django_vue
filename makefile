SHELL := /bin/sh

# SET THIS! Directory containing wsgi.py
# PROJECT := someproject

LOCALPATH := ./src
PYTHONPATH := $(LOCALPATH)/
SETTINGS := production
DJANGO_SETTINGS_MODULE = $(PROJECT).settings.$(SETTINGS)
DJANGO_POSTFIX := --settings=$(DJANGO_SETTINGS_MODULE) --pythonpath=$(PYTHONPATH)
LOCAL_SETTINGS := local
DJANGO_LOCAL_SETTINGS_MODULE = $(PROJECT).settings.$(LOCAL_SETTINGS)
DJANGO_LOCAL_POSTFIX := --settings=$(DJANGO_LOCAL_SETTINGS_MODULE) --pythonpath=$(PYTHONPATH)
TEST_SETTINGS := test
DJANGO_TEST_SETTINGS_MODULE = $(PROJECT).settings.$(TEST_SETTINGS)
DJANGO_POSTFIX := --settings=$(DJANGO_SETTINGS_MODULE) --pythonpath=$(PYTHONPATH)
DJANGO_TEST_POSTFIX := --settings=$(DJANGO_TEST_SETTINGS_MODULE) --pythonpath=$(PYTHONPATH)
PYTHON_BIN := $(VIRTUAL_ENV)/bin

.PHONY: clean showenv coverage test bootstrap pip virtualenv sdist virtual_env_set

showenv:
	@echo 'Environment:'
	@echo '-----------------------'
	@$(PYTHON_BIN)/python -c "import sys; print 'sys.path:', sys.path"
	@echo 'PYTHONPATH:' $(PYTHONPATH)
	@echo 'PROJECT:' $(PROJECT)
	@echo 'DJANGO_SETTINGS_MODULE:' $(DJANGO_SETTINGS_MODULE)
	@echo 'DJANGO_LOCAL_SETTINGS_MODULE:' $(DJANGO_LOCAL_SETTINGS_MODULE)
	@echo 'DJANGO_TEST_SETTINGS_MODULE:' $(DJANGO_TEST_SETTINGS_MODULE)

showenv.all: showenv showenv.virtualenv showenv.site

showenv.virtualenv: virtual_env_set
	PATH := $(VIRTUAL_ENV)/bin:$(PATH)
	export $(PATH)
	@echo 'VIRTUAL_ENV:' $(VIRTUAL_ENV)
	@echo 'PATH:' $(PATH)

showenv.site: site_set
	@echo 'SITE:' $(SITE)

djangohelp: virtual_env_set
	$(PYTHON_BIN)/django-admin.py help $(DJANGO_POSTFIX)

collectstatic: virtual_env_set
	-mkdir -p .$(LOCALPATH)/static
	$(PYTHON_BIN)/django-admin.py collectstatic -c --noinput $(DJANGO_POSTFIX)

o: virtual_env_set
	python manage.py runserver "192.168.1.60:8090"

ms: virtual_env_set
	python manage.py makemigrations

mt: virtual_env_set
	python manage.py migrate

sms: virtual_env_set
	python manage.py showmigrations

d: virtual_env_set
	python manage.py runserver 159.65.116.234:8090

l: virtual_env_set
	python manage.py runserver localhost:8090

h: virtual_env_set
	python manage.py runserver 192.168.0.103:8000

lp: virtual_env_set
	POLAR_LOG=1 python manage.py runserver

rock: virtual_env_set
	 ssh -R 80:localhost:8000 localhost.run

celery: virtual_env_set
	celery -A itaraproject worker -B -l info

freeze: virtual_env_set
	pip freeze > requirements.txt

#celery_beat: virtual_env_set
#	celery -A itaraproject beat -l info



check: virtual_env_set
	python manage.py check

static: virtual_env_set
	python manage.py collectstatic

compress: virtual_env_set
	python manage.py compress --force

es: virtual_env_set
	python manage.py search_index --rebuild

cities: virtual_env_set
	python manage.py cities_light

load_cities: virtual_env_set
	python manage.py cities_light_fixtures load

dump_cities: virtual_env_set
	python manage.py cities_light_fixtures dump

dumpnow: virtual_env_set
	python manage.py dumpdata  --exclude auth.permission  --exclude aadmin.companypermission  --exclude aadmin.companyrole  --exclude aadmin.companyrolepermission  --exclude aadmin.companyuser  --exclude aadmin.companyteam  --exclude aadmin.companyteamuser  --exclude aadmin.companydoctype  --exclude aadmin.companydoctypesuser  --exclude aadmin.companydoctypesteam  --exclude contenttypes > db5.json

syncdb: virtual_env_set
	$(PYTHON_BIN)/django-admin.py syncdb $(DJANGO_POSTFIX)

cmd: virtual_env_set
	$(PYTHON_BIN)/django-admin.py $(CMD) $(DJANGO_POSTFIX)

localcmd: virtual_env_set
	$(PYTHON_BIN)/django-admin.py $(CMD) $(DJANGO_LOCAL_POSTFIX)

refresh:
	touch src/$(PROJECT)/*wsgi.py

rsync:
	rsync -avz --checksum --exclude-from .gitignore --exclude-from .rsyncignore . ${REMOTE_URI}

compare:
	rsync -avz --checksum --dry-run --exclude-from .gitignore --exclude-from .rsyncignore . ${REMOTE_URI}

clean:
	find . -name "*.pyc" -print0 | xargs -0 rm -rf
	-rm -rf htmlcov
	-rm -rf .coverage
	-rm -rf build
	-rm -rf dist
	-rm -rf src/*.egg-info

test: clean virtual_env_set
	-$(PYTHON_BIN)/coverage run $(PYTHON_BIN)/django-admin.py test $(APP) $(DJANGO_TEST_POSTFIX)

coverage: virtual_env_set
	$(PYTHON_BIN)/coverage html --include="$(LOCALPATH)/*" --omit="*/admin.py,*/test*"

predeploy: test

register: virtual_env_set
	python setup.py register

sdist: virtual_env_set
	python setup.py sdist

upload: sdist virtual_env_set
	python setup.py upload
	make clean

bootstrap: virtualenv pip virtual_env_set

pip: requirements/$(SETTINGS).txt virtual_env_set
	pip install -r requirements/$(SETTINGS).txt

virtualenv:
	virtualenv --no-site-packages $(VIRTUAL_ENV)
	echo $(VIRTUAL_ENV)

all: collectstatic refresh
