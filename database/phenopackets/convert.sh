# Create a folder for the v2 phenopackets.
# mkdir -p v2

# pxf="java -jar /home/rodtheo/Bioinfo/tools/phenopacket-tools-cli-1.0.0-RC3/phenopacket-tools-cli-1.0.0-RC3.jar"

# Convert the phenopackets.
for pp in $(find phenopackets -name "*.json"); do
  pp_name=$(basename ${pp})
  echo $pp
  java -jar /home/rodtheo/Bioinfo/tools/phenopacket-tools-cli-1.0.0-RC3/phenopacket-tools-cli-1.0.0-RC3.jar convert --convert-variants ${pp} > v2/${pp_name}
done

printf "Converted %s phenopackets\n" $(ls v2/ | wc -l)
