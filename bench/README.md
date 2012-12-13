## Prepare

	bundle install
	ruby stub_server.rb

## Run

	ruby em_bench.rb

or

	bundle exec rainbows -c rainbows.rb em_rainbows_bench.ru

or

	GREEN_HUB=EM bundle exec rainbows -c rainbows.rb green_bench.ru

or

	bundle exec rainbows -c rainbows.rb sync_bench.ru

or

	bundle exec unicorn -c unicorn.rb block_pool_bench.ru

or

	bundle exec puma -b tcp://0.0.0.0:8080 -t 100:100 block_pool_bench.ru

## Start

	tsung -f http_simple.xml start


## Results


<img src="prepor.github.com/ulya2012/imagesg/request_count_all.jpg"></img>

<img src="prepor.github.com/ulya2012/imagesg/request_count.jpg"></img>

<img src="prepor.github.com/ulya2012/imagesg/request_count.jpg"></img>