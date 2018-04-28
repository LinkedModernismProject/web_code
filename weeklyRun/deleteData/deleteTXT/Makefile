all: sh

sh: update_search update_relfinder

update_search: batch_delete_data.sh
	./batch_delete_data.sh

update_relfinder: batch_delete_data_RelFinder.sh
	./batch_delete_data_RelFinder.sh
	