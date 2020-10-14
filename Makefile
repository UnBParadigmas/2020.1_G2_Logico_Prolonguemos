lib:
	- mkdir lib
	git clone https://github.com/khueue/prolog-bson ./lib/prolog-bson
	git clone https://github.com/khueue/prolongo ./lib/prolongo

db:
    tar -xf yelp/yelp_dataset.tar -C yelp/
	docker-compose exec mongo mongoimport -d yelp -c business /data/yelp/yelp_academic_dataset_business.json
