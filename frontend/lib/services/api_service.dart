import 'api/admin_api.dart';
import 'api/auth_api.dart';
import 'api/base_api.dart';
import 'api/catalogs_api.dart';
import 'api/chat_api.dart';
import 'api/client_api.dart';
import 'api/groups_api.dart';
import 'api/infrastructure_api.dart';
import 'api/instructor_api.dart';
import 'api/manager_api.dart';
import 'api/recommendation_api.dart';
import 'api/schedule_api.dart';
import '../modules/equipment/models/equipment/equipment_item.model.dart';
import '../modules/equipment/models/equipment/equipment_type.model.dart';
import '../modules/roles/models/role.dart';
import '../models/schedule_item.dart';
import '../modules/rooms/models/building/building.model.dart';
import '../modules/rooms/models/room/room.model.dart';
import '../modules/users/models/user.dart';
import '../modules/chat/models/chat_models.dart';
import '../models/whtr_profiles.dart';
import '../models/goal_training.dart';
import '../models/level_training.dart';
import '../modules/groups/models/training_group.model.dart';
import '../modules/groups/models/analytic_group.model.dart';
import '../modules/groups/models/group_schedule.model.dart';
import 'package:fitman_app/modules/equipment/models/equipment/equipment_category.enum.dart';
import '../modules/groups/models/training_group_type.model.dart';


class ApiService {
  // Instantiate all the modular services
  static final AuthApiService _authApi = AuthApiService();
  static final InfrastructureApiService _infrastructureApi = InfrastructureApiService();
  static final GroupsApiService _groupsApi = GroupsApiService();
  static final ChatApiService _chatApi = ChatApiService();
  static final ManagerApiService _managerApi = ManagerApiService();
  static final InstructorApiService _instructorApi = InstructorApiService();
  static final ClientApiService _clientApi = ClientApiService();
  static final CatalogsApiService _catalogsApi = CatalogsApiService();
  static final ScheduleApiService _scheduleApi = ScheduleApiService();
  static final AdminApiService _adminApi = AdminApiService();
  static final RecommendationApiService _recommendationApi = RecommendationApiService();


  // --- Token and Session Management ---
  static Future<void> init() => BaseApiService.init();
  static Future<void> saveToken(String token) => BaseApiService.saveToken(token);
  static Future<void> clearToken() => BaseApiService.clearToken();
  static String? get currentToken => BaseApiService.currentToken;
  static String get baseUrl => BaseApiService.baseUrl;

  // --- Auth & User Methods ---
  static Future<AuthResponse> login(String email, String password) =>
      _authApi.login(email, password);

  static Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    required List<String> roles,
    String? phone,
    String? gender,
    DateTime? dateOfBirth,
  }) =>
      _authApi.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        roles: roles,
        phone: phone,
        gender: gender,
        dateOfBirth: dateOfBirth,
      );

  static Future<User> checkTokenAndGetUser() => _authApi.checkTokenAndGetUser();
  static Future<User> createUser(CreateUserRequest request) => _authApi.createUser(request);
  static Future<User> updateUser(UpdateUserRequest request) => _authApi.updateUser(request);
  static Future<List<User>> getUsers({String? role, int? offset, int? limit, bool? isArchived}) =>
      _authApi.getUsers(role: role, offset: offset, limit: limit, isArchived: isArchived);
  static Future<User> getUserById(int userId) => _authApi.getUserById(userId);
  static Future<List<Role>> getAllRoles() => _authApi.getAllRoles();
  static Future<List<Role>> getUserRoles(int userId) => _authApi.getUserRoles(userId);
  static Future<void> updateUserRoles(int userId, List<String> roleNames) =>
      _authApi.updateUserRoles(userId, roleNames);
  static Future<void> archiveUser(int userId, {String? reason}) =>
      _authApi.archiveUser(userId, reason: reason);
  static Future<Map<String, dynamic>> uploadAvatar(List<int> photoBytes, String fileName, int userId) =>
      _authApi.uploadAvatar(photoBytes, fileName, userId);
  static Future<void> resetUserPassword(int userId, String newPassword) =>
      _authApi.resetUserPassword(userId, newPassword);

  // --- Infrastructure Methods ---
  static Future<List<Room>> getAllRooms({String? buildingId, int? roomType, bool? isActive, bool? isArchived}) =>
      _infrastructureApi.getAllRooms(
          buildingId: buildingId, roomType: roomType, isActive: isActive, isArchived: isArchived);
  static Future<Room> getRoomById(String id) => _infrastructureApi.getRoomById(id);
  static Future<Room> createRoom(Room room) => _infrastructureApi.createRoom(room);
  static Future<Room> updateRoom(String id, Room room) => _infrastructureApi.updateRoom(id, room);
  static Future<void> deleteRoom(String id) => _infrastructureApi.deleteRoom(id);

  static Future<List<Building>> getAllBuildings({bool? isArchived}) =>
      _infrastructureApi.getAllBuildings(isArchived: isArchived);
  static Future<Building> getBuildingById(String id) => _infrastructureApi.getBuildingById(id);
  static Future<Building> createBuilding(Building building) => _infrastructureApi.createBuilding(building);
  static Future<Building> updateBuilding(String id, Building building) =>
      _infrastructureApi.updateBuilding(id, building);
  static Future<void> deleteBuilding(String id) => _infrastructureApi.deleteBuilding(id);

  static Future<List<EquipmentItem>> getAllEquipmentItems({String? roomId}) =>
      _infrastructureApi.getAllEquipmentItems(roomId: roomId);
  static Future<EquipmentItem> getEquipmentItemById(String id) =>
      _infrastructureApi.getEquipmentItemById(id);

  static Future<List<EquipmentType>> getAllEquipmentTypes({EquipmentCategory? category}) =>
      _infrastructureApi.getAllEquipmentTypes(category: category);
  static Future<EquipmentType> getEquipmentTypeById(String id) =>
      _infrastructureApi.getEquipmentTypeById(id);
  static Future<EquipmentType> createEquipmentType(EquipmentType equipmentType) =>
      _infrastructureApi.createEquipmentType(equipmentType);
  static Future<EquipmentType> updateEquipmentType(String id, EquipmentType equipmentType) =>
      _infrastructureApi.updateEquipmentType(id, equipmentType);
  static Future<void> deleteEquipmentType(String id) => _infrastructureApi.deleteEquipmentType(id);


  // --- Group Methods ---
  static Future<List<TrainingGroup>> getAllTrainingGroups({
    String? searchQuery,
    int? groupTypeId,
    bool? isActive,
    bool? isArchived,
    int? trainerId,
    int? instructorId,
    int? managerId,
  }) =>
      _groupsApi.getAllTrainingGroups(
        searchQuery: searchQuery,
        groupTypeId: groupTypeId,
        isActive: isActive,
        isArchived: isArchived,
        trainerId: trainerId,
        instructorId: instructorId,
        managerId: managerId,
      );
  static Future<TrainingGroup> getTrainingGroupById(int id) => _groupsApi.getTrainingGroupById(id);
  static Future<TrainingGroup> createTrainingGroup(TrainingGroup group) => _groupsApi.createTrainingGroup(group);
  static Future<TrainingGroup> updateTrainingGroup(TrainingGroup group) => _groupsApi.updateTrainingGroup(group);
  static Future<void> deleteTrainingGroup(int id) => _groupsApi.deleteTrainingGroup(id);

  static Future<List<AnalyticGroup>> getAllAnalyticGroups({bool? isActive, bool? isArchived}) =>
      _groupsApi.getAllAnalyticGroups(isActive: isActive, isArchived: isArchived);
  static Future<AnalyticGroup> getAnalyticGroupById(int id) => _groupsApi.getAnalyticGroupById(id);
  static Future<AnalyticGroup> createAnalyticGroup(AnalyticGroup group) => _groupsApi.createAnalyticGroup(group);
  static Future<AnalyticGroup> updateAnalyticGroup(AnalyticGroup group) => _groupsApi.updateAnalyticGroup(group);
  static Future<void> deleteAnalyticGroup(int id) => _groupsApi.deleteAnalyticGroup(id);

  static Future<List<GroupSchedule>> getGroupSchedules(int groupId) => _groupsApi.getGroupSchedules(groupId);
  static Future<GroupSchedule> createGroupSchedule(int groupId, GroupSchedule slot) =>
      _groupsApi.createGroupSchedule(groupId, slot);
  static Future<GroupSchedule> updateGroupSchedule(GroupSchedule slot) => _groupsApi.updateGroupSchedule(slot);
  static Future<void> deleteGroupSchedule(int id) => _groupsApi.deleteGroupSchedule(id);

  static Future<List<int>> getTrainingGroupMembers(int groupId) => _groupsApi.getTrainingGroupMembers(groupId);
  static Future<void> addTrainingGroupMember(int groupId, int userId) =>
      _groupsApi.addTrainingGroupMember(groupId, userId);
  static Future<void> removeTrainingGroupMember(int groupId, int userId) =>
      _groupsApi.removeTrainingGroupMember(groupId, userId);

  static Future<List<TrainingGroupType>> getAllTrainingGroupTypes() => _groupsApi.getAllTrainingGroupTypes();


  // --- Chat Methods ---
  static Future<List<Chat>> getChats() => _chatApi.getChats();
  static Future<List<Message>> getMessages(int chatId, {int limit = 50, int offset = 0}) =>
      _chatApi.getMessages(chatId, limit: limit, offset: offset);
  static Future<int> createOrGetPrivateChat(int peerId) => _chatApi.createOrGetPrivateChat(peerId);
  static Future<Chat> createGroupChat(String name, List<int> memberIds) =>
      _chatApi.createGroupChat(name, memberIds);
  static Future<Message> uploadChatAttachment(
          {required int chatId, required List<int> fileBytes, required String fileName}) =>
      _chatApi.uploadChatAttachment(chatId: chatId, fileBytes: fileBytes, fileName: fileName);


  // --- Manager Methods ---
  static Future<List<User>> getAssignedClients(int managerId) => _managerApi.getAssignedClients(managerId);
  static Future<List<User>> getAssignedInstructors(int managerId) =>
      _managerApi.getAssignedInstructors(managerId);
  static Future<List<User>> getAssignedTrainers(int managerId) => _managerApi.getAssignedTrainers(managerId);

  static Future<List<int>> getAssignedClientIds(int managerId) => _managerApi.getAssignedClientIds(managerId);
  static Future<List<int>> getAssignedInstructorIds(int managerId) =>
      _managerApi.getAssignedInstructorIds(managerId);
  static Future<List<int>> getAssignedTrainerIds(int managerId) => _managerApi.getAssignedTrainerIds(managerId);

  static Future<void> assignClientsToManager(int managerId, List<int> clientIds) =>
      _managerApi.assignClientsToManager(managerId, clientIds);
  static Future<void> assignInstructorsToManager(int managerId, List<int> instructorIds) =>
      _managerApi.assignInstructorsToManager(managerId, instructorIds);
  static Future<void> assignTrainersToManager(int managerId, List<int> trainerIds) =>
      _managerApi.assignTrainersToManager(managerId, trainerIds);


  // --- Instructor Methods ---
  static Future<List<User>> getAssignedClientsForInstructor(int instructorId) =>
      _instructorApi.getAssignedClientsForInstructor(instructorId);
  static Future<List<User>> getAssignedTrainersForInstructor(int instructorId) =>
      _instructorApi.getAssignedTrainersForInstructor(instructorId);
  static Future<User> getAssignedManagerForInstructor(int instructorId) =>
      _instructorApi.getAssignedManagerForInstructor(instructorId);


  // --- Client Methods ---
  static Future<Map<String, dynamic>> getClientDashboardData() => _clientApi.getClientDashboardData();
  static Future<User> getTrainerForClient() => _clientApi.getTrainerForClient();
  static Future<User> getInstructorForClient() => _clientApi.getInstructorForClient();
  static Future<User> getManagerForClient() => _clientApi.getManagerForClient();

  static Future<Map<String, dynamic>> getOwnAnthropometryData() => _clientApi.getOwnAnthropometryData();
  static Future<String> getSomatotypeProfile() => _clientApi.getSomatotypeProfile();
  static Future<WhtrProfiles> getWhtrProfiles() => _clientApi.getWhtrProfiles();

  static Future<void> updateAnthropometryFixed({required int height, required int wristCirc, required int ankleCirc}) =>
      _clientApi.updateAnthropometryFixed(height: height, wristCirc: wristCirc, ankleCirc: ankleCirc);

  static Future<void> updateAnthropometryMeasurements(
          {required String type,
          required double weight,
          required int shouldersCirc,
          required int breastCirc,
          required int waistCirc,
          required int hipsCirc}) =>
      _clientApi.updateAnthropometryMeasurements(
          type: type,
          weight: weight,
          shouldersCirc: shouldersCirc,
          breastCirc: breastCirc,
          waistCirc: waistCirc,
          hipsCirc: hipsCirc);

  static Future<Map<String, dynamic>> uploadAnthropometryPhoto(
          {required List<int> photoBytes,
          required String fileName,
          required String type,
          DateTime? photoDateTime}) =>
      _clientApi.uploadAnthropometryPhoto(
          photoBytes: photoBytes, fileName: fileName, type: type, photoDateTime: photoDateTime);
          
  static Future<User> updateClientProfile(Map<String, dynamic> profileData) =>
      _clientApi.updateClientProfile(profileData);
  static Future<Map<String, dynamic>> getCalorieTrackingData() =>
      _clientApi.getCalorieTrackingData();
  static Future<Map<String, dynamic>> getClientPreferences() =>
      _clientApi.getClientPreferences();
  static Future<void> saveClientPreferences(Map<String, dynamic> preferences) =>
      _clientApi.saveClientPreferences(preferences);
  static Future<Map<String, dynamic>> getProgressData() =>
      _clientApi.getProgressData();


  // --- Catalog and Schedule Methods ---
  static Future<List<dynamic>> getTrainingPlans() => _catalogsApi.getTrainingPlans();
  static Future<List<GoalTraining>> getTrainingGoals() => _catalogsApi.getTrainingGoals();
  static Future<List<LevelTraining>> getTrainingLevels() => _catalogsApi.getTrainingLevels();
  static Future<List<ScheduleItem>> getSchedule() => _scheduleApi.getSchedule();
  static Future<List<dynamic>> getWorkSchedules() => _scheduleApi.getWorkSchedules();
  static Future<void> updateWorkSchedule(Map<String, dynamic> schedule) =>
      _scheduleApi.updateWorkSchedule(schedule);

  static Future<Map<String, dynamic>> getRecommendation(int clientId) =>
      _recommendationApi.getRecommendation(clientId);


  // --- Admin Methods ---
  static Future<Map<String, dynamic>> getAnthropometryDataForClient(int clientId) =>
      _adminApi.getAnthropometryDataForClient(clientId);
  static Future<String> getSomatotypeProfileForClient(int clientId) =>
      _adminApi.getSomatotypeProfileForClient(clientId);
  static Future<WhtrProfiles> getWhtrProfilesForClient(int clientId) =>
      _adminApi.getWhtrProfilesForClient(clientId);
  
  static Future<void> updateAnthropometryFixedForClient({
    required int clientId,
    required int height,
    required int wristCirc,
    required int ankleCirc,
  }) => _adminApi.updateAnthropometryFixedForClient(
      clientId: clientId, height: height, wristCirc: wristCirc, ankleCirc: ankleCirc);

  static Future<void> updateAnthropometryMeasurementsForClient({
    required int clientId,
    required String type,
    required double weight,
    required int shouldersCirc,
    required int breastCirc,
    required int waistCirc,
    required int hipsCirc,
  }) => _adminApi.updateAnthropometryMeasurementsForClient(
      clientId: clientId,
      type: type,
      weight: weight,
      shouldersCirc: shouldersCirc,
      breastCirc: breastCirc,
      waistCirc: waistCirc,
      hipsCirc: hipsCirc);
  
  static Future<Map<String, dynamic>> uploadAnthropometryPhotoForClient({
    required int clientId,
    required List<int> photoBytes,
    required String fileName,
    required String type,
    DateTime? photoDateTime,
  }) => _adminApi.uploadAnthropometryPhotoForClient(
      clientId: clientId,
      photoBytes: photoBytes,
      fileName: fileName,
      type: type,
      photoDateTime: photoDateTime);
}