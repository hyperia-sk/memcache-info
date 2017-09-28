#!/bin/bash
set -o errexit

# prints usage
# $1 exit value
usage() {
cat <<EOF

    Command show statistics of Memcached"

    $0 [ -h ] -n HOST_NAME -p PORT

    where options are:

  	-h, prints help
	-n, name of the host or IP address
	-p, port

EOF
exit $1
}

OPTERR=0
while getopts ":n:p:h" options
do
    case $options in
	  n) HOST_NAME=$OPTARG
	  ;;
      p) PORT=$OPTARG
      ;;
	  h) usage 0
	  ;;
    esac
done

# getopts will take his params, but rest of them ara available after shifting is done.
shift $(($OPTIND - 1))

if [ -z "$HOST_NAME" ]; then
	echo ""
	echo "Hostname or IP is not set"
	usage 1
fi

if [ -z "$PORT" ]; then
	echo ""
	echo "Port is not set"
	usage 1
fi

# get slabStats
slabStats=$( mktemp )
echo "stats slabs" | nc $HOST_NAME $PORT > $slabStats

# get stats
stats=$( mktemp )
echo "stats" | nc $HOST_NAME $PORT > $stats

function isInteger() 
{
    [[ ${1} == ?(-)+([0-9]) ]]
}

function _echo
{
    echo -e "$1"
}

function _echoB
{
    _echo "\033[1m$1\033[0m"
}

scale=2
function _calc
{
    _echo "scale=$scale; $@" | bc -l | sed 's/^\./0./'
}

function _drawSparkLine
{
    chart="";
    scale=1
    percent=$(_calc "(($1/$2)*100)/5" );
    for i in `seq 0 $percent`
    do
        chart=$chart"█"
    done

    echo $chart
}

red=$(tput setaf 1)
green=$(tput setaf 2)
yellow=$(tput setaf 3)
normal=$(tput sgr0)
readonly format="%-18s %-10s %-30s\n"

function getStatsInfo() 
{
    cat $stats | grep "STAT $1" | awk '{ print $3 }' | tr -d '\r'
}

function getSummaryInfo() 
{

    echo ""
    _echoB "Memcache Quick Stats"
    echo ""
    printf "$format" "Version" "$(getStatsInfo "version")"
    printf "$format" "Uptime" "~"$(_calc $(getStatsInfo "uptime")/86400)" days"
    printf "$format" "PID" $(getStatsInfo "pid")
    scale=0
    printf "$format" "Total items" $(getStatsInfo "curr_items")
    printf "$format" "Set requests" $(getStatsInfo "cmd_set")
    printf "$format" "Flush requests" $(getStatsInfo "cmd_flush")



    echo ""
    _echoB "Time info"
    echo ""
    printf "$format" "User" "$(date)"
    printf "$format" "Memcache" "$(date --date="@$(getStatsInfo "time ")")"
    

    echo ""
    _echoB "Connection info"
    echo ""
    printf "$format" "Current" $(getStatsInfo "curr_connections")
    printf "$format" "Total" $(getStatsInfo "total_connections")    


    echo ""
    _echoB "Get info"
    echo ""
    totalHits=$(getStatsInfo "get_hits")
    totalMisses=$(getStatsInfo "get_misses")
    totalRequests=$(_calc $totalHits+$totalMisses)

    scale=2    
    printf "$format" "Requests" $totalRequests
    printf "$format" "Hits" "$totalHits" "$(_drawSparkLine $totalHits $totalRequests) ($(_calc 100*$totalHits/$totalRequests)%)"
    printf "$format" "Misses" "$totalMisses" "$(_drawSparkLine $totalMisses $totalRequests) ($(_calc 100*$totalMisses/$totalRequests)%)"


    echo ""
    _echoB "Delete info"
    echo ""
    totalHits=$(getStatsInfo "delete_hits")
    totalMisses=$(getStatsInfo "delete_misses")
    totalRequests=$(_calc $totalHits+$totalMisses)
    scale=2
    printf "$format" "Requests" $totalRequests
    printf "$format" "Hits" "$totalHits" "$(_drawSparkLine $totalHits $totalRequests) ($(_calc 100*$totalHits/$totalRequests)%)"
    printf "$format" "Misses" "$totalMisses" "$(_drawSparkLine $totalMisses $totalRequests) ($(_calc 100*$totalMisses/$totalRequests)%)"
}

function getMemoryInfo() 
{
    maxMemory=$( getLimitMaxBytes )
    totalMemory=$( getTotalMemory )
    totalMemoryUsed=$( getTotalMemoryUsed )
    totalMemoryWasted=$( getTotalMemoryWasted )
    
    echo ""
    _echoB "Memory info"
    echo ""
    
    printf "$format" "Total allocated" "$(_calc "($totalMemory)/1024/1024") MB"
    printf "$format" "Total used" "$(_calc "($totalMemoryUsed)/1024/1024") MB"
    printf "$format" "Total wasted" "$(_calc "($totalMemoryWasted)/1024/1024") MB"

    printf "$format" "Max memory" "$(_calc "($maxMemory)/1024/1024") MB"
    freeMemory=$( echo "$maxMemory - ($totalMemoryUsed + $totalMemoryWasted)" | bc )
    printf "$format" "Free" "$(_calc "($freeMemory)/1024/1024") MB"
}

function getLimitMaxBytes() 
{
	cat $stats | grep "STAT limit_maxbytes" | awk '{ print $3}' | tr -d '\r'
}

#
# $1 - slab number
# $2 - stat info you want to get
# e.g. getStatInfo 1 chunk_size will return chunk size of slab 1
#
function getSlabInfo() 
{
	cat $slabStats | grep "STAT $1:$2" | awk '{ print $3}' | tr -d '\r'
}

#
# Gets total amount of memory that is used by all items.
#
function getTotalMemory() 
{
	cat $slabStats | grep "STAT total_malloced" | awk '{ print $3}' | tr -d '\r'
}

# How much memory is realy used by this slab
# $1 - slab id
function getSlabMemoryUsed() 
{
	getSlabInfo $1 "mem_requested"
}

# How much memory is wasted by this slab
# $1 - slab id
function getSlabMemoryWasted() 
{
		totalChunks=$( getSlabInfo $1 "total_chunks")
		usedChunks=$( getSlabInfo $1 "used_chunks")
		chunkSize=$( getSlabInfo $1 "chunk_size")
		memRequested=$( getSlabMemoryUsed $1 )

        if isInteger $memRequested; then
		    totalChunksSize=$( echo "$totalChunks * $chunkSize" | bc)
		    if [ "$totalChunksSize" -lt "$memRequested" ]; then
			    memoryWasted=$( echo "($totalChunks - $usedChunks) * $chunkSize" | bc )
		    else
			    memoryWasted=$( echo "$totalChunks * $chunkSize - $memRequested" | bc )
		    fi
        fi

		echo $memoryWasted
}

# Gets total amount of memory used (doesn't include wasted memory)
function getTotalMemoryUsed() 
{
		numberOfSlabs=$( cat $slabStats | grep "STAT active_slabs" | awk '{ print $3}' | tr -d '\r' )
		totalMemoryUsed=0

		for i in `seq 1 $numberOfSlabs`; 
        do
			memoryUsed=$( getSlabMemoryUsed $i )
            if isInteger $memoryUsed; then
                totalMemoryUsed=$( echo "$totalMemoryUsed + $memoryUsed" | bc )	
            fi
			done

		echo $totalMemoryUsed
}

function getTotalMemoryWasted() 
{
	numberOfSlabs=$( cat $slabStats | grep "STAT active_slabs" | awk '{ print $3}' | tr -d '\r' )
	totalMemoryWasted=0

	for i in $(seq 1 $numberOfSlabs);
    do
        memoryWasted=$( getSlabMemoryWasted $i )
        if isInteger $memoryWasted; then
		    totalMemoryWasted=$( echo "$totalMemoryWasted + $memoryWasted" | bc )
        fi	
    done

	echo $totalMemoryWasted
}



getSummaryInfo
getMemoryInfo
echo ""
