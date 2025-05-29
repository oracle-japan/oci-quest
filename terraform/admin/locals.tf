locals {
  all_services = data.oci_core_services.all_services.services.0
  protocol = {
    all  = "all"
    icmp = "1"
    tcp  = "6"
  }
}

locals {
  namespace = data.oci_objectstorage_namespace.mushop_namespace.namespace
}

locals {
  members = jsondecode(base64decode(var.members_file))

  flattened_members = flatten([
    for team in local.members.teams : [
      for email in team.members : {
        team_name  = team.name
        email      = email
      }
    ]
  ])

  member_map = {
    for member in local.flattened_members :
    split("@", member.email)[0] => {
      team_name = member.team_name
      email     = member.email
    }
  }
  
  team_map = {
    for team in local.members.teams :
    team.name => {
        description = team.description
    }
    }
}

locals {
  full_high_strings = {
    for team, db in oci_database_autonomous_database.mushop_atp :
    team => db.connection_strings[0].high
  }

  high_service_names = {
    for team, high in local.full_high_strings :
    team => regex("/(.+)$", high)[0]
  }
}


# チーム名のリスト
locals {
  team_names = keys(local.team_map)
}

# チーム名 → OCIDのマップを構築
locals {
  team_compartment_ocids = {
    for team_name in local.team_names :
    team_name => [
      for c in data.oci_identity_compartments.all_compartments.compartments : c
      if c.name == team_name
    ][0].id
  }
}

locals {
  image_files = fileset("./images", "**")

  team_image_pairs = {
    for pair in setproduct(keys(local.team_compartment_ocids), local.image_files) :
    "${pair[0]}:${pair[1]}" => {
      team  = pair[0]
      image = pair[1]
    }
  }
}
