#!/bin/sh

# A POSIX variable
OPTIND=1         # Reset in case getopts has been used previously in the shell.

# Initialize variables to default values
angle=0.0;
scale=1.0;
width=0;
height=0;
method='vizinho';
inImg='house.ppm';
output='out.ppm';

while getopts "a:s:e:w:h:m:i:o:" opt; do
	case "$opt" in
		e|s)scale=$OPTARG
				;;
		a)	angle=$OPTARG
				;;
		w)	width=$OPTARG
				;;
		h)	height=$OPTARG
				;;
		m)	method=$OPTARG
				;;
		i)	inImg=$OPTARG
				;;
		o)	output=$OPTARG
				;;
	esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

echo "Executing octave with"
octave --silent lab04.m $angle $scale $width $height $method $inImg $output
# End of file
