# Create a folder for the v2 phenopackets.
# mkdir -p v2

# pxf="java -jar /home/rodtheo/Bioinfo/tools/phenopacket-tools-cli-1.0.0-RC3/phenopacket-tools-cli-1.0.0-RC3.jar"

# Convert the phenopackets.
for pp in $(find v2 -name "*.json"); do
  pp_name=$(basename ${pp})
  echo $pp
  python json_to_single_line.py ${pp} > v2_single_line/${pp_name}
done

printf "Converted %s phenopackets json to single line json\n" $(ls v2_single_line/ | wc -l)
