#!/bin/sh
echo Gerando imagens por interpolacao...

./lab04.sh -s 1.25 -i monarch.ppm -o monarch1.25vizinho.ppm  -m vizinho &
./lab04.sh -s 1.25 -i house.ppm -o house1.25vizinho.ppm  -m vizinho &
./lab04.sh -s 1.25 -i baboon.ppm -o baboon1.25vizinho.ppm  -m vizinho &
./lab04.sh -s 4 -i house.ppm -o house4vizinho1000x1000.ppm  -m vizinho -w 1000 -h 1000 &
wait

./lab04.sh -s 1.25 -i monarch.ppm -o monarch1.25bilinear.ppm  -m bilinear &
./lab04.sh -s 1.25 -i house.ppm -o house1.25bilinear.ppm  -m bilinear &
./lab04.sh -s 1.25 -i baboon.ppm -o baboon1.25bilinear.ppm  -m bilinear &
./lab04.sh -s 2 -i house.ppm -o house2bilinear500x500.ppm  -m bilinear -w 500 -h 500 &
wait

./lab04.sh -s 1.25 -i monarch.ppm -o monarch1.25bicubica.ppm  -m bicubica &
./lab04.sh -s 1.25 -i house.ppm -o house1.25bicubica.ppm  -m bicubica &
./lab04.sh -s 1.25 -i baboon.ppm -o baboon1.25bicubica.ppm  -m bicubica &
./lab04.sh -s 2 -i house.ppm -o house2bicubica500x500.ppm  -m bicubica -w 500 -h 500 &
wait

./lab04.sh -s 1.25 -i monarch.ppm -o monarch1.25lagrange.ppm  -m lagrange &
./lab04.sh -s 1.25 -i house.ppm -o house1.25lagrange.ppm  -m lagrange &
./lab04.sh -s 1.25 -i baboon.ppm -o baboon1.25lagrange.ppm  -m lagrange &
./lab04.sh -s 2 -i house.ppm -o house2lagrange500x500.ppm  -m lagrange -w 500 -h 500 &
wait

./lab04.sh -a 45 -i monarch.ppm -o monarch45anglevizinho.ppm  -m vizinho 1>/dev/null &
./lab04.sh -a 45 -i house.ppm -o house45anglevizinho.ppm  -m vizinho 1>/dev/null &
./lab04.sh -a 100 -i baboon.ppm -o baboon100anglevizinho.ppm  -m vizinho 1>/dev/null &
wait

./lab04.sh -a 180 -i house.ppm -o house180anglebilinear.ppm  -m bilinear &
./lab04.sh -a 45 -i baboon.ppm -o baboon45anglebilinear.ppm  -m bilinear &
wait

./lab04.sh -a 20 -i monarch.ppm -o monarch20anglebicubica.ppm  -m bicubica &
./lab04.sh -a 270 -i house.ppm -o house270anglebicubica.ppm  -m bicubica &
./lab04.sh -a 250 -i baboon.ppm -o baboon250anglebicubica.ppm  -m bicubica &
./lab04.sh -a 330 -i monarch.ppm -o monarch330anglelagrange.ppm  -m lagrange &
wait
