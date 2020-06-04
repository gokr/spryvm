nim c -f -d:release -d:danger --passC:-ffast-math benchmarks

date  >> log.txt
git log -1 >> log.txt
./benchmarks >> log.txt
echo "--------------------" >> log.txt
