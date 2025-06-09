locals {
  members = jsondecode(base64decode(var.members_file))

  // フラット化したメンバーリスト（重複除去前）
  flattened_members_raw = flatten([
    for team in local.members.teams : [
      for email in team.members : {
        team_name  = team.name
        email      = email
      }
    ]
  ])

  // 重複除去（team_nameとemailの組み合わせで一意にする）
  flattened_members = [
    for obj in distinct([
      for m in local.flattened_members_raw : "${m.team_name}:${m.email}"
    ]) : {
      team_name = split(":", obj)[0]
      email     = split(":", obj)[1]
    }
  ]

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