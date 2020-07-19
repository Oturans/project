USER_NAME = oturans
GCP_PROJECT = project-otus-283004

#----------------------------------------------------Docker-compose 
compose-up:
	cd src && docker-compose up -d

compose-down:
	cd src && docker-compose down

#---------------------------------------------------Terraform GKE
infra-install: gke-create helm-install nginx-install Gitalb-install Prometheus-install grafana-install

gke-create:
	cd infra/terraform && terraform init
	cd infra/terraform && terraform apply -auto-approve
	gcloud container clusters get-credentials my-gke-cluster --region us-central1 --project $(GCP_PROJECT)

gke-destroy:
	cd infra/terraform && terraform destroy

#----------------------------------------------------Helm Install
helm-install:
	cd infra/helm && kubectl apply -f tiller.yml
	cd infra/helm && helm init --service-account tiller
	sleep 10

#---------------------------------------------------Nginx
nginx-install:
	#helm install stable/nginx-ingress --name nginx
	helm upgrade nginx stable/nginx-ingress --install

#---------------------------------------------------GitlabCi
Gitalb-install:
	#cd infra/gitlab-omnibus && helm install --name gitlab . -f values.yaml
	cd infra/gitlab-omnibus && helm upgrade gitlab . -f values.yaml --install

#----------------------------------------------------Prometheus
Prometheus-install:
	cd infra/prometheus && helm upgrade prom . -f custom_values.yml --install

#----------------------------------------------------Grafana
grafana-install:
	cd infra/grafana && helm upgrade grafana . -f custom_values.yaml --install

#----------------------------------------------------Helm Install
#search-install:
#	cd charts/search && helm del --purge search 
#	cd charts/search && helm dep update   
#	cd charts/search && helm upgrade search . --install
#	cd charts && helm list

#---------------------------------------------------BUILD

build-all: build-ui build-crawler


build-ui:
	cd ./src/search-engine-ui && docker build -t ${USER_NAME}/search-ui .

build-crawler:
	cd ./src/search-engine-crawler && docker build -t ${USER_NAME}/search-crawler .


#---------------------------------------------------PUSH

push-all: push-ui push-crawler 

push-ui:
	docker push ${USER_NAME}/search-ui

push-crawler:
	docker push ${USER_NAME}/search-crawler
