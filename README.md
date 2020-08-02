


## Project .....  

#### Описание приложения и его архитектура  

Приложение состоит из 4 компонентов  
	- База данных - mongoDB  
	- Очередь сообщений - rabbitMQ  
	- Парсес сайтов - Crawler  
	- Графический интерфейс - UI  

![Схема приложения](https://github.com/Oturans/project/blob/master/src/crawler-ui.png)

Дополнительно был добавлен mongoExporter для сбора метрик в рамках конкретного Stage  

**Как реализовано:**  
Мы подымаем Кластер Kubernetes  
и уже в рамках кластера разворачиваем все что нам надо в рамках infra:  
	1. Gitlab - Git/CI/CD  
	2. Prometheus - Сбор метрик как с кубера, так и автодискавери с наших приложений  
	3. Grafana - визуализация метрик (тут будут готовые дашборды)  
	4. Alertmanager - предупреждения  

Наше приложение разворачивается (review/staging/production) автоматически Gitlab-ом в Kubernetes.  
За счет заранее настроенных /etc/hosts и Nginx Ingress мы можем посмотреть конкретное приложение.  

#### Что сделано:  

1. Настроено поднятие кластера в GKE + firewall через terraform  
```
	cd infra/terraform && terraform init
	cd infra/terraform && terraform apply -auto-approve
	gcloud container clusters get-credentials my-gke-cluster /
		--region us-central1 /
		--project $(GCP_PROJECT)
```
2. Настроено автоматическое разворачивание инфраструктуры через kubectl/helm  
   
   2.1. В обшем то сам Helm через Kubectl  
   2.2. Nginx в качестве ingress, используется по умолчанию, ничего не менял  
   2.3. Gitlab-omnibus взять готовый из домашки.  
   2.4. Prometheus за основу взят из домашки, добавлено автодискавери  
   UI/Crawler/MongoExporter  
   2.5. Alermanager настроено уведомление в slack и на почту
   
   2.6. Grafana - Датастор(prometheus) + 2 дашборда(Кубер взят готовый и Собрал свой по UI/Crawler), оба дашборда загружаются с grafana.com в процессе install. 

3. Разворачивание и настройка infra происходит на этапе Install, весь процес выполняется с помощью утилиты make.  
   Итоговый файл можно посмотреть тут [**Makefile**][6]
```
#---------------------Helm-install---------------------------------------------

	cd infra/helm && kubectl apply -f tiller.yml
	cd infra/helm && helm init --service-account tiller

#---------------------Nginx-install--------------------------------------------

	helm upgrade nginx stable/nginx-ingress --install

#---------------------Gitlab-install-------------------------------------------

	cd infra/gitlab-omnibus && helm upgrade gitlab . -f values.yaml --install

#---------------------Prometheus-install---------------------------------------

	cd infra/prometheus && helm upgrade prom . -f custom_values.yml --install

#---------------------Grafana-install------------------------------------------

	cd infra/grafana && helm upgrade grafana . -f custom_values.yaml --install
```

4. Исходники приложения:  
		[/src/search-engine-crawler][1]  
		[/src/search-engine-ui][2]   
	Там же настроены докер файлы для сборки приложений в докер контейнеры:  
		[/src/search-engine-crawler/Dockerfile][3]  
		[/src/search-engine-ui/Dockerfile][4]  
5. Для лольного теста приложения собрал приложение в docker-compose  
	Запустить из / **make compose-up**  
	Удалить из / **make compose-down**  

6. Для разворачивания созданы чарты на каждое приложени, в том числе 
   1. mongoDB  
   2. rebbitMQ  
   3. MongoExporter  

	[/charts/][5]  

#### Что требуется для запуска?  

1. Создать проект в GCP
2. Настроить доступ с локальной машины в GCP (gcloud/gsutil)
3. Teraform / Helm / Kubectl / git

#### Как запустить?

1. Качаем репу **git clone https://github.com/Oturans/project.git**
2. Редактируем **Makefile**, меняем переменные на свои  
```
USER_NAME = oturans 				< --- логин на DockerHub  
GCP_PROJECT = project-otus-283004  	< --- ID проекта в GCP  
```
Сохраняем файл.

3. Из корня папки запускаем **make infra-install**

4. Ждем... (...можно сделать кофе, покурить...)  

5. Смотрим  внешний IP выданный Nginx-Controller и добавяем в /etc/hosts строку вида
```
GCP-IP prometheus grafana gitlab-gitlab production staging  
```
5. Первым делом открываем сайт https://gitlab-gitlab/

устанавливаем пароль
Заходим в Gitlab

Создаем группу = dockerlogin  
создаем 3 проекта:  
search-deploy (этот создаем обязательно первым)  
search-engine-ui  
search-engine-crawler  

грузим из репы  
**search-deploy**			< --- /charts/  
**search-engine-ui**		< --- /src/search-engine-ui/  
**search-engine-crawler**	< --- /src/search-engine-crawler/  

Необходимо добавить 3 переменных на группу:  
**CI_REGISTRY_USER**    	< --- логин на DockerHub  
**CI_REGISTRY_PASSWORD**	< --- пароль на DockerHub  
**token** 					< --- токен, генерим в разделе CI/CD в репе  

В принципе все, можно пользоватся.  

https://prometheus/

https://grafana/
	логин: admin
	пароль: admin321


#### Что осталось?
1. ScreenCast - записать по готоновсти.  
2. Доработка описания.  
3. что то чего я еще не учел.....   

#### RAW TEXT..... (To be continue... )

	P.S. Кто то из преподов говорил, первое время это будет копипаст, весь проект, это копипаст домашек процентов на 95.... 



[1]:https://github.com/Oturans/project/tree/master/src/search-engine-crawler
[2]:https://github.com/Oturans/project/tree/master/src/search-engine-ui
[3]:https://raw.githubusercontent.com/Oturans/project/master/src/search-engine-crawler/Dockerfile
[4]:https://raw.githubusercontent.com/Oturans/project/master/src/search-engine-ui/Dockerfile
[5]:https://github.com/Oturans/project/tree/master/charts
[6]:https://raw.githubusercontent.com/Oturans/project/master/Makefile
