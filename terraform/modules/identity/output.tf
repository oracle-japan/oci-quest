# output "all_compartment_ocids" {
#   value = data.oci_identity_compartments.all_compartments.compartments[*].id
# }

output "teamname_to_compartment_ocid_map" {
  description = "Map from team name to compartment OCID"
  value = {
    for team_name, comp in oci_identity_compartment.teams :
    team_name => comp.id
  }
}
