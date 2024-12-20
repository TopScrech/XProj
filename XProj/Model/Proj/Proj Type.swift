enum ProjType: String, Decodable {
    case proj,
         workspace,
         package,
         vapor,
         playground,
         unknown
}
