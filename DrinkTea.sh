#! /bin/bash
_USER_NAME=$1
twurl set default ${_USER_NAME}

# Backup Followers List
_FOLLOWERSCOUNT=`twurl /1.1/users/show.json?screen_name=${_USER_NAME} | jq .followers_count`
if [ "${_FOLLOWERSCOUNT}" -gt 5000 ]; then
	_CURSOR=-1
	_FOLLOWER_ID_ARRAY=()
	until [ "${_CURSOR}" -eq 0 ];
	do
		_REMAINING=`twurl /1.1/application/rate_limit_status.json | jq '.resources.followers."/followers/ids".remaining'`
		for (( i=1 ; i<"${_REMAINING}" ; i++ ));
		do
			_FOLLOWER_ID_ARRAY+=(`twurl "/1.1/followers/ids.json?cursor=$_CURSOR&screen_name=${_USER_NAME}&count=5000" | json-query ids next_cursor`)
			_CURSOR=${_FOLLOWER_ID_ARRAY[-1]}
			unset '_FOLLOWER_ID_ARRAY[${#_FOLLOWER_ID_ARRAY[@]}-1]'
			if [ "${_CURSOR}" -eq 0 ];then 
				i=${_REMAINING};
			fi;
		done
		if [ "${_CURSOR}" -ne 0 ];then 
			let _SLEEP=`twurl /1.1/application/rate_limit_status.json | jq '.resources.followers."/followers/ids".reset'`-`date +%s`
			sleep ${_SLEEP};
		fi;
	done;
else
	_FOLLOWER_ID_ARRAY=()
	_FOLLOWER_ID_ARRAY=(`twurl /1.1/followers/ids.json?screen_name=${_USER_NAME} | json-query ids`);
fi
_FOLLOWER_NAME_ARRAY=()
_REMAINING=`twurl /1.1/application/rate_limit_status.json | jq '.resources.users."/users/show/:id".remaining'`
j=1
for i in "${_FOLLOWER_ID_ARRAY[@]}";
do
	if [ "${j}" -le "${_REMAINING}" ];then
		_USER=`twurl /1.1/users/show.json?user_id=${i} | jq -r '[.name, .screen_name] | @csv' | sed 's/"//g'`
		_FOLLOWER_NAME_ARRAY+=("${_USER} |")
		((j++));
	else
		let _SLEEP=`twurl /1.1/application/rate_limit_status.json | jq '.resources.users."/users/show/:id".reset'`-`date +%s`
		sleep ${_SLEEP}
		_REMAINING=`twurl /1.1/application/rate_limit_status.json | jq '.resources.users."/users/show/:id".remaining'`
		j=1;
	fi;
done

# Backup Friends List
_FRIENDSCOUNT=`twurl /1.1/users/show.json?screen_name=${_USER_NAME} | jq .friends_count`
if [ "${_FRIENDSCOUNT}" -gt 5000 ]; then
	_CURSOR=-1
	_FRIEND_ID_ARRAY=()
	until [ "${_CURSOR}" -eq 0 ];
	do
		_REMAINING=`twurl /1.1/application/rate_limit_status.json | jq '.resources.friends."/friends/ids".remaining'`
		for (( i=1 ; i<"${_REMAINING}" ; i++ ));
		do
			_FRIEND_ID_ARRAY+=(`twurl "/1.1/friends/ids.json?cursor=$_CURSOR&screen_name=${_USER_NAME}&count=5000" | json-query ids next_cursor`)
			_CURSOR=${_FRIEND_ID_ARRAY[-1]}
			unset '_FRIEND_ID_ARRAY[${#_FRIEND_ID_ARRAY[@]}-1]'
			if [ "${_CURSOR}" -eq 0 ];then 
				i=${_REMAINING};
			fi;
		done
		if [ "${_CURSOR}" -ne 0 ];then 
			let _SLEEP=`twurl /1.1/application/rate_limit_status.json | jq '.resources.friends."/friends/ids".reset'`-`date +%s`
			sleep ${_SLEEP};
		fi;
	done;
else
	_FRIEND_ID_ARRAY=()
	_FRIEND_ID_ARRAY=(`twurl /1.1/friends/ids.json?screen_name=${_USER_NAME} | json-query ids`);
fi
_FRIEND_NAME_ARRAY=()
_REMAINING=`twurl /1.1/application/rate_limit_status.json | jq '.resources.users."/users/show/:id".remaining'`
j=1
for i in "${_FRIEND_ID_ARRAY[@]}";
do
	if [ "${j}" -le "${_REMAINING}" ];then
		_USER=`twurl /1.1/users/show.json?user_id=${i} | jq -r '[.name, .screen_name] | @csv' | sed 's/"//g'`
		_FRIEND_NAME_ARRAY+=("${_USER} |")
		((j++));
	else
		let _SLEEP=`twurl /1.1/application/rate_limit_status.json | jq '.resources.users."/users/show/:id".reset'`-`date +%s`
		sleep ${_SLEEP}
		_REMAINING=`twurl /1.1/application/rate_limit_status.json | jq '.resources.users."/users/show/:id".remaining'`
		j=1;
	fi;
done

# Backup Block List
_BLOCKCOUNT=`twurl /1.1/blocks/ids.json | jq .ids[] | wc -l`
if [ "${_BLOCKCOUNT}" -gt 5000 ]; then
	_CURSOR=-1
	_BLOCK_ID_ARRAY=()
	until [ "${_CURSOR}" -eq 0 ];
	do
		_REMAINING=`twurl /1.1/application/rate_limit_status.json | jq '.resources.blocks."/blocks/ids".remaining'`
		for (( i=1 ; i<"${_REMAINING}" ; i++ ));
		do
			_BLOCK_ID_ARRAY+=(`twurl "/1.1/blocks/ids.json?screen_name=${_USER_NAME}&cursor=$_CURSOR&count=5000" | json-query ids next_cursor`)
			_CURSOR=${_BLOCK_ID_ARRAY[-1]}
			unset '_BLOCK_ID_ARRAY[${#_BLOCK_ID_ARRAY[@]}-1]'
			if [ "${_CURSOR}" -eq 0 ];then 
				i=${_REMAINING};
			fi;
		done
		if [ "${_CURSOR}" -ne 0 ];then 
			let _SLEEP=`twurl /1.1/application/rate_limit_status.json | jq '.resources.blocks."/blocks/ids".reset'`-`date +%s`
			sleep ${_SLEEP};
		fi;
	done;
else
	_BLOCK_ID_ARRAY=()
	_BLOCK_ID_ARRAY=(`twurl /1.1/blocks/ids.json?screen_name=${_USER_NAME} | json-query ids`);
fi
_BLOCK_NAME_ARRAY=()
_REMAINING=`twurl /1.1/application/rate_limit_status.json | jq '.resources.users."/users/show/:id".remaining'`
j=1
for i in "${_BLOCK_ID_ARRAY[@]}";
do
	if [ "${j}" -le "${_REMAINING}" ];then
		_USER=`twurl /1.1/users/show.json?user_id=${i} | jq -r '[.name, .screen_name] | @csv' | sed 's/"//g'`
		_BLOCK_NAME_ARRAY+=("${_USER} |")
		((j++));
	else
		let _SLEEP=`twurl /1.1/application/rate_limit_status.json | jq '.resources.users."/users/show/:id".reset'`-`date +%s`
		sleep ${_SLEEP}
		_REMAINING=`twurl /1.1/application/rate_limit_status.json | jq '.resources.users."/users/show/:id".remaining'`
		j=1;
	fi;
done

# Backup Mute List
_MUTECOUNT=`twurl /1.1/mutes/users/list.json | jq .users[].id_str | wc -l`
if [ "${_MUTECOUNT}" -gt 5000 ]; then
	_CURSOR=-1
	_MUTE_ID_ARRAY=()
	until [ "${_CURSOR}" -eq 0 ];
	do
		_REMAINING=`twurl /1.1/application/rate_limit_status.json | jq '.resources.mutes."/mutes/users/ids".remaining'`
		for (( i=1 ; i<"${_REMAINING}" ; i++ ));
		do
			_MUTE_ID_ARRAY+=(`twurl "/1.1/mutes/users/ids.json?screen_name=${_USER_NAME}&cursor=$_CURSOR&count=5000" | json-query ids next_cursor`)
			_CURSOR=${_MUTE_ID_ARRAY[-1]}
			unset '_MUTE_ID_ARRAY[${#_MUTE_ID_ARRAY[@]}-1]'
			if [ "${_CURSOR}" -eq 0 ];then 
				i=${_REMAINING};
			fi;
		done
		if [ "${_CURSOR}" -ne 0 ];then 
			let _SLEEP=`twurl /1.1/application/rate_limit_status.json | jq '.resources.mutes."/mutes/users/ids".reset'`-`date +%s`
			sleep ${_SLEEP};
		fi;
	done;
else
	_MUTE_ID_ARRAY=()
	_MUTE_ID_ARRAY=(`twurl /1.1/mutes/users/ids.json?screen_name=${_USER_NAME} | json-query ids`);
fi
_MUTE_NAME_ARRAY=()
_REMAINING=`twurl /1.1/application/rate_limit_status.json | jq '.resources.users."/users/show/:id".remaining'`
j=1
for i in "${_MUTE_ID_ARRAY[@]}";
do
	if [ "${j}" -le "${_REMAINING}" ];then
		_USER=`twurl /1.1/users/show.json?user_id=${i} | jq -r '[.name, .screen_name] | @csv' | sed 's/"//g'`
		_MUTE_NAME_ARRAY+=("${_USER} |")
		((j++));
	else
		let _SLEEP=`twurl /1.1/application/rate_limit_status.json | jq '.resources.users."/users/show/:id".reset'`-`date +%s`
		sleep ${_SLEEP}
		_REMAINING=`twurl /1.1/application/rate_limit_status.json | jq '.resources.users."/users/show/:id".remaining'`
		j=1;
	fi;
done

# DELETE ALL TWEETS
_NO_TWEET=`twurl /1.1/users/show.json?screen_name=${_USER_NAME} | jq '.statuses_count'`
_TWEETS_ID_LIST=()
while [ "${_NO_TWEET}" -gt 0 ];
do
	_TWEETS_ID_LIST=(`twurl "/1.1/statuses/user_timeline.json?screen_name=${_USER_NAME}&count=200" | jq -r '.[].id_str'`)
	for i in "${_TWEETS_ID_LIST[@]}";
	do
		_DELETE_TWEET=`twurl -X POST /1.1/statuses/destroy/$i.json`;
	done
	_NO_TWEET=`twurl /1.1/users/show.json?screen_name=${_USER_NAME} | jq '.statuses_count'`
	if [ "${_NO_TWEET}" -gt 0 ]; then 
		sleep 900;
	fi;
done

# Unfollow Friends
for i in "${_FRIEND_ID_ARRAY[@]}";
do
	_DELETE_FRIEND=`twurl -X POST /1.1/friendships/destroy.json?user_id=${i}`;
done

echo -e "${_USER_NAME}" >> /var/DrinkTea/static/${_USER_NAME}".txt"
echo -e "----------------FOLLOWER----------------\n" >> /var/DrinkTea/static/${_USER_NAME}".txt"
echo ${_FOLLOWER_NAME_ARRAY[@]} >> /var/DrinkTea/static/${_USER_NAME}".txt"
echo -e "----------------FOLLOWER END----------------\n" >> /var/DrinkTea/static/${_USER_NAME}".txt"
echo -e "----------------FRIEND----------------\n" >> /var/DrinkTea/static/${_USER_NAME}".txt"
echo ${_FRIEND_NAME_ARRAY[@]} >> /var/DrinkTea/static/${_USER_NAME}".txt"
echo -e "----------------FRIEND END----------------\n" >> /var/DrinkTea/static/${_USER_NAME}".txt"
echo -e "----------------BLOCK----------------\n" >> /var/DrinkTea/static/${_USER_NAME}".txt"
echo ${_BLOCK_NAME_ARRAY[@]} >> /var/DrinkTea/static/${_USER_NAME}".txt"
echo -e "----------------BLOCK END----------------\n" >> /var/DrinkTea/static/${_USER_NAME}".txt"
echo -e "----------------MUTE----------------\n" >> /var/DrinkTea/static/${_USER_NAME}".txt"
echo ${_MUTE_NAME_ARRAY[@]} >> /var/DrinkTea/static/${_USER_NAME}".txt"
echo -e "----------------MUTE END----------------\n" >> /var/DrinkTea/static/${_USER_NAME}".txt"
_SHA=`sha256sum /var/DrinkTea/static/${_USER_NAME}".txt" | awk '{print $1}'`
mv /var/DrinkTea/static/${_USER_NAME}".txt"  /var/DrinkTea/static/${_SHA}".txt"
qrencode -o /var/DrinkTea/static/${_SHA}".png" 'http://54.189.14.27:8443/static/'${_SHA}'.txt'
sleep 1
if [ -a "/var/DrinkTea/static/"${_SHA}".png" ];then
	echo ${_SHA}".png";
else
	echo "QRcode generate unsuccessfully";
fi
