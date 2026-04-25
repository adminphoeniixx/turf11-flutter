import '../../core/api_client.dart';
import '../../core/api_constants.dart';
import '../models/team_model.dart';

class TeamService {
  static Future<List<TeamModel>> fetchMyTeams() async {
    final res = await ApiClient.get(ApiConstants.teams);
    final root = _toMap(res.data);
    final myTeams = _extractTeams(root['my_teams'])
        .map(
          (team) => team.copyWith(
            isCaptain: true,
            canManage: true,
          ),
        )
        .toList();
    final joinedTeams = _extractTeams(root['joined_teams'])
        .map(
          (team) => team.copyWith(
            isCaptain: false,
            canManage: false,
          ),
        )
        .toList();

    final combined = <TeamModel>[
      ...myTeams,
      ...joinedTeams,
    ];
    if (combined.isNotEmpty) {
      return _hydrateTeams(combined);
    }

    final candidates = [root['teams'], root['data'], root];
    for (final candidate in candidates) {
      final teams = _extractTeams(candidate);
      if (teams.isNotEmpty) {
        return _hydrateTeams(teams);
      }
    }

    return const <TeamModel>[];
  }

  static Future<TeamModel> fetchTeamDetail(int teamId) async {
    final res = await ApiClient.get(ApiConstants.teamDetail(teamId));
    final root = _toMap(res.data);
    if (root.isEmpty) {
      return const TeamModel(
        id: 0,
        name: 'Team',
        sport: '-',
        city: '-',
        code: '',
        isCaptain: false,
        canManage: false,
        memberCount: 0,
        captainName: '',
        members: <TeamMemberModel>[],
      );
    }
    return TeamModel.fromJson(root);
  }

  static Future<TeamActionResult> createTeam({
    required String name,
    required String sport,
    required String city,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.teams,
      data: {
        'name': name,
        'sport': sport,
        'city': city,
      },
    );
    return _readActionResult(res.data);
  }

  static Future<TeamActionResult> updateTeam({
    required int teamId,
    required String name,
    required String sport,
    required String city,
  }) async {
    final res = await ApiClient.put(
      ApiConstants.teamDetail(teamId),
      data: {
        'name': name,
        'sport': sport,
        'city': city,
      },
    );
    return _readActionResult(res.data);
  }

  static Future<TeamActionResult> deleteTeam(int teamId) async {
    final res = await ApiClient.delete(ApiConstants.teamDetail(teamId));
    return _readActionResult(res.data);
  }

  static Future<TeamInviteModel> fetchInviteLink(int teamId) async {
    final res = await ApiClient.get(ApiConstants.teamInviteLink(teamId));
    final root = _toMap(res.data);
    return TeamInviteModel.fromJson(root);
  }

  static Future<TeamActionResult> joinTeamByCode(String code) async {
    final res = await ApiClient.post(
      ApiConstants.joinTeam,
      data: {'code': code},
    );
    return _readActionResult(res.data);
  }

  static Future<TeamActionResult> removeMember({
    required int teamId,
    required int memberId,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.teamRemoveMember(teamId, memberId),
    );
    return _readActionResult(res.data);
  }

  static Future<TeamActionResult> leaveTeam(int teamId) async {
    final res = await ApiClient.post(ApiConstants.teamLeave(teamId));
    return _readActionResult(res.data);
  }

  static Future<TeamTournamentRegistrationResult> registerTeamForTournament({
    required int tournamentId,
    required int playerTeamId,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.tournamentRegister(tournamentId),
      data: {'player_team_id': playerTeamId},
    );
    final root = _toMap(res.data);
    return TeamTournamentRegistrationResult.fromJson(root);
  }

  static Future<List<NearbyPlayerModel>> fetchNearbyPlayers({
    required double lat,
    required double lng,
    int radius = 10,
  }) async {
    final res = await ApiClient.get(
      ApiConstants.nearbyPlayers,
      queryParameters: {
        'lat': lat,
        'lng': lng,
        'radius': radius,
      },
    );
    final root = _toMap(res.data);
    final candidates = [
      root['players'],
      root['data'],
      root['items'],
      res.data,
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map(
              (item) => NearbyPlayerModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }
      if (candidate is Map<String, dynamic>) {
        for (final key in const ['data', 'players', 'items']) {
          final nested = candidate[key];
          if (nested is List) {
            return nested
                .whereType<Map>()
                .map(
                  (item) => NearbyPlayerModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList();
          }
        }
      }
    }

    return const <NearbyPlayerModel>[];
  }

  static Future<TeamActionResult> invitePlayer({
    required int playerId,
    required String type,
    required int referenceId,
    required String message,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.invitePlayer,
      data: {
        'player_id': playerId,
        'type': type,
        'reference_id': referenceId,
        'message': message,
      },
    );
    return _readActionResult(res.data);
  }

  static Future<List<PlayerInvitationModel>> fetchInvitations() async {
    final res = await ApiClient.get(ApiConstants.invitations);
    final root = _toMap(res.data);
    final candidates = [
      root['invitations'],
      root['data'],
      root['items'],
      res.data,
    ];

    for (final candidate in candidates) {
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map(
              (item) => PlayerInvitationModel.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }
      if (candidate is Map<String, dynamic>) {
        for (final key in const ['data', 'invitations', 'items']) {
          final nested = candidate[key];
          if (nested is List) {
            return nested
                .whereType<Map>()
                .map(
                  (item) => PlayerInvitationModel.fromJson(
                    Map<String, dynamic>.from(item),
                  ),
                )
                .toList();
          }
        }
      }
    }

    return const <PlayerInvitationModel>[];
  }

  static Future<TeamActionResult> respondToInvitation({
    required int invitationId,
    required String response,
  }) async {
    final res = await ApiClient.post(
      ApiConstants.respondInvitation(invitationId),
      data: {'response': response},
    );
    return _readActionResult(res.data);
  }

  static TeamActionResult _readActionResult(dynamic data) {
    final root = _toMap(data);
    if (root.isEmpty) {
      return const TeamActionResult(
        success: false,
        message: 'Unexpected response received.',
      );
    }
    return TeamActionResult.fromJson(root);
  }

  static Future<List<TeamModel>> _hydrateTeams(List<TeamModel> teams) async {
    final hydrated = await Future.wait(
      teams.map((team) async {
        if (team.id <= 0) {
          return team;
        }
        try {
          final detail = await fetchTeamDetail(team.id);
          return detail.copyWith(
            isCaptain: team.isCaptain,
            canManage: team.canManage,
            code: detail.code.isNotEmpty ? detail.code : team.code,
            captainName: detail.captainName.isNotEmpty
                ? detail.captainName
                : team.captainName,
          );
        } catch (_) {
          return team;
        }
      }),
    );
    return hydrated;
  }

  static List<TeamModel> _extractTeams(dynamic candidate) {
    if (candidate is List) {
      return candidate
          .whereType<Map>()
          .map((item) => TeamModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (candidate is Map<String, dynamic>) {
      for (final key in const ['data', 'items', 'teams']) {
        final nested = candidate[key];
        if (nested is List) {
          return nested
              .whereType<Map>()
              .map((item) => TeamModel.fromJson(Map<String, dynamic>.from(item)))
              .toList();
        }
      }
    }

    return const <TeamModel>[];
  }

  static Map<String, dynamic> _toMap(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    }
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }
    return <String, dynamic>{};
  }
}
