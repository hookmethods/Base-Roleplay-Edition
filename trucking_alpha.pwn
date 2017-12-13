#include <a_samp>
#include <streamer>
#include <dini>
#include <zcmd>
#include <sscanf2>
#include <foreach>
#include <vehicleplus>

#define FILTERSCRIPT

#define DELIVERY_FOLDER "trucker/%d.ini"
#define MAX_D_POINT 50 // 最多50个收购/买货点
#define DIALOG_MANAGE_IND   3000
#define DIALOG_ADD_IND      3001
#define DIALOG_IND_NAME     3002
#define DIALOG_IND_TYPE		3003
#define DIALOG_IND_STOCK	3004
#define DIALOG_IND_MAIN		3005
#define DIALOG_IND_PRICE	3006
#define DIALOG_TRUCKERPDA   3007
#define	DIALOG_ALL_IND      3008
#define	DIALOG_PDA_SEL      3009
#define DIALOG_CARGO_LIST   3010

#define MAX_CARGOS 40


// 个人属性 在OnPlayerSpawn里重置 并且OBJ离线/死亡 时删除, 车辆同样
new countDPoint;
new countTimer;
new VehicleObject[MAX_VEHICLES][MAX_CARGOS];
new vehCargo[MAX_VEHICLES];
new bool:CarryingCrate[MAX_PLAYERS]; 
new cargoType[MAX_VEHICLES];
new cargoPrice[MAX_VEHICLES];
new serversidetimer = 12240000;
new servertime;

#define MAX_DROPPED_CRATE 200

enum dcInfo
{
	dcID, // 自有ID
	Float:dcPos[3],
 	dcType,
 	dcPrice,
 	dcExpTime,
 	Text3D:dcText,
 	dcObject,
 	crateOwner[MAX_PLAYER_NAME] // 每个人最多丢2个
}
new dCrates[MAX_DROPPED_CRATE][dcInfo];

enum session_trucker_enum
{
    deliverID,
    deliverName[128],
    Float:deliverX,
    Float:deliverY,
    Float:deliverZ,
    deliverPrice, // 多少钱一个货物
    deliverType, // 商品类型 只在卡车司机的PDA里面显示
    deliverPickup,
	Text3D:deliverLabel,
	deliverMain, // 总存货
 	deliverRun, // 是否收购/出售 如果存货等于0 那就显示关门 每3个小时更新一次存货 只更新关门的收购站
	deliverStock, // 当前仓库存货
	deliverWanted[3] // 需求 0 为类型 1为价格 2为需求数量
};
/* 按工作等级来

	if(GetPVarInt(playerid, "editIND_Type") == 0) format(type, 48, "未设置");
	else if(GetPVarInt(playerid, "editIND_Type") == 1) format(type,48,"水果");
	else if(GetPVarInt(playerid, "editIND_Type") == 2) format(type,48,"猪肉");
	else if(GetPVarInt(playerid, "editIND_Type") == 3) format(type,48,"鸡蛋");
	else if(GetPVarInt(playerid, "editIND_Type") == 4) format(type,48,"服装");
	else if(GetPVarInt(playerid, "editIND_Type") == 5) format(type,48,"车辆零件"); // 需要一台运送车辆的train truck, 价格80W一台 跑一次差不多几千块钱
	else if(GetPVarInt(playerid, "editIND_Type") == 6) format(type,48,"木材"); // 运送加工材料，给组织使用
	else if(GetPVarInt(playerid, "editIND_Type") == 7) format(type,48,"军火"); // 需要组织权限并且政府组织需要这个才能得到武器
*/
new Job_Trucker[MAX_D_POINT][session_trucker_enum];

main()
{
	print("物流系统 0.1");
}

public OnFilterScriptInit()
{
	LoadDPoint();
	countDPoint = 0;
	SetTimer("droppedCrate", 1000, true);
	serversidetimer = randomEx(3600000, 10800000);
	servertime = SetTimer("refresh_storage", serversidetimer, true); // 3小时
	print("droppedCrate 计时器开始");
	return 1;
}

public OnFilterScriptExit()
{
	SaveDPoint();
	return 1;
}

forward refresh_storage(); // 调整价格幅度 等等 并且保存
public refresh_storage()
{
	for(new i = 0; i != MAX_D_POINT; i++)
	{
	    if(Job_Trucker[i][deliverID] == 0 || Job_Trucker[i][deliverID] == -1) continue;
	    if(Job_Trucker[i][deliverStock] == Job_Trucker[i][deliverMain]) Job_Trucker[i][deliverPrice] -= randomEx(1, 20); 
        if(Job_Trucker[i][deliverStock] <= 20) Job_Trucker[i][deliverWanted][2] += (Job_Trucker[i][deliverPrice] - Job_Trucker[i][deliverWanted][2]) * (1+randomEx(1, 20)*0.001);
	    if(Job_Trucker[i][deliverWanted][2] >= 30) continue;
		session_refresh_storage(i);
	}
}

forward droppedCrate();
public droppedCrate()
{
	for(new i = 0; i != MAX_DROPPED_CRATE; i++)
	{
		if(dCrates[i][dcID] > 0)
		{
            if(dCrates[i][dcExpTime] > 0)
            {
                dCrates[i][dcExpTime]--;
            }
            else
            {
                if(IsValidDynamicObject(dCrates[i][dcObject])) DestroyDynamicObject(dCrates[i][dcObject]);
                if(IsValidDynamic3DTextLabel(dCrates[i][dcText])) DestroyDynamic3DTextLabel(dCrates[i][dcText]);
                printf("[控制台] >> 箱子 %d 由于长时间未拾取被系统删除了.", dCrates[i][dcID]);
				dCrates[i][dcID] = -1;
				format(dCrates[i][crateOwner], MAX_PLAYER_NAME, "None");
				dCrates[i][dcPos][0] = 0.0;
				dCrates[i][dcPos][1] = 0.0;
				dCrates[i][dcPos][2] = 0.0;
				dCrates[i][dcType] = -1;
				dCrates[i][dcPrice] = -1;
	            dCrates[i][dcExpTime] = 0;
            }
		}
	}
}

stock row_industry()
{
	new ID[64];
	for(new h = 0; h <= MAX_D_POINT; h++)
	{
		format(ID, sizeof(ID), DELIVERY_FOLDER, h);
		if(!dini_Exists(ID)) return h;
	}
	return 1;
}

forward SaveDPoint();
public SaveDPoint()
{
	new string[128];
 	for(new ID = 0; ID < sizeof(Job_Trucker); ID++)
	{
	    format(string, sizeof(string), DELIVERY_FOLDER, ID);
	    if(dini_Exists(string))
	    {
	        dini_IntSet(string,"ID", Job_Trucker[ID][deliverID]);
	        dini_Set(string,"Name", Job_Trucker[ID][deliverName]);
		 	dini_FloatSet(string,"Xpos", Job_Trucker[ID][deliverX]);
		  	dini_FloatSet(string,"Ypos", Job_Trucker[ID][deliverY]);
		   	dini_FloatSet(string,"Zpos", Job_Trucker[ID][deliverZ]);
		   	dini_IntSet(string,"Price", Job_Trucker[ID][deliverPrice]);
		   	dini_IntSet(string,"Type", Job_Trucker[ID][deliverType]);
		   	dini_IntSet(string,"Main", Job_Trucker[ID][deliverMain]);
		   	dini_IntSet(string,"Run", Job_Trucker[ID][deliverRun]);
		   	dini_IntSet(string,"Stock", Job_Trucker[ID][deliverStock]);
	    }
    }
    return 1;
}
forward LoadDPoint();
public LoadDPoint()
{
	new string[70], labeldesc[300];
    for(new ID = 0; ID < sizeof(Job_Trucker); ID++)
	{
		format(string, sizeof(string), DELIVERY_FOLDER, ID);
	    if(dini_Exists(string))
		{
		    Job_Trucker[ID][deliverID] = dini_Int(string, "ID");
		    strmid(Job_Trucker[ID][deliverName], dini_Get(string,"Name"), 0, 128, 128);
			Job_Trucker[ID][deliverX] = dini_Float(string, "Xpos");
		   	Job_Trucker[ID][deliverY] = dini_Float(string, "Ypos");
		    Job_Trucker[ID][deliverZ] = dini_Float(string, "Zpos");
            Job_Trucker[ID][deliverPrice] = dini_Int(string, "Price");
            Job_Trucker[ID][deliverType] = dini_Int(string, "Type");
            Job_Trucker[ID][deliverMain] = dini_Int(string, "Main");
            Job_Trucker[ID][deliverRun] = dini_Int(string, "Run");
            Job_Trucker[ID][deliverStock] = dini_Int(string, "Stock");
   			
   			Job_Trucker[ID][deliverWanted][0] = randomEx(1, 4);
   			if(Job_Trucker[ID][deliverType] == Job_Trucker[ID][deliverWanted][0])
			   Job_Trucker[ID][deliverWanted][0] = randomEx(1, 4), printf("[控制台] >> 工业区#%d需求类型等于出售类型, 系统已修正为 %s", ID, ReturnCargoName(Job_Trucker[ID][deliverWanted][0]));
			   
   			Job_Trucker[ID][deliverWanted][1] = Job_Trucker[ID][deliverPrice] + randomEx(1, 10);
   			Job_Trucker[ID][deliverWanted][2] = floatround((Job_Trucker[ID][deliverMain] - randomEx(10, 30)) * 0.25);
			format(labeldesc, sizeof(labeldesc), "[{FFFF00}%s{FFFFFF}]\n{C3C3C3}库存: %d / %d\n价格: $%d / 单件", Job_Trucker[ID][deliverName], Job_Trucker[ID][deliverStock], Job_Trucker[ID][deliverMain], Job_Trucker[ID][deliverPrice]);
   			Job_Trucker[ID][deliverLabel] = CreateDynamic3DTextLabel(labeldesc, -1, Job_Trucker[ID][deliverX], Job_Trucker[ID][deliverY], Job_Trucker[ID][deliverZ]+1.0, 30.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 100.0);
            Job_Trucker[ID][deliverPickup] = CreateDynamicPickup(1318, 1, Job_Trucker[ID][deliverX], Job_Trucker[ID][deliverY], Job_Trucker[ID][deliverZ], 0, -1, -1, 30.0);
            countDPoint ++;
   		}
	}
	printf("[控制台] >> 已成功读取%d个工业区.", countDPoint);
	return 1;
}

CMD:industry(playerid, params[])
{
    SetStringVar(playerid, "editIND_Name", "未设置");
	ShowPlayerDialog(playerid, DIALOG_MANAGE_IND, DIALOG_STYLE_LIST, "工业区控制台", "创建工业区\n修改工业区\n删除最近的工业区\n补货管理", "选择", "取消"); // 补货管理意味着设置补货时间 比如3个小时一次 一次多少多少个
	return 1;
}
CMD:pda(playerid, params[])
{
	GivePlayerMoney(playerid, 10000);
	ShowPlayerDialog(playerid, DIALOG_TRUCKERPDA, DIALOG_STYLE_LIST, "卡车司机 - PDA", "{C3C3C3}查看{FFFFFF}工业园区\n{C3C3C3}查看{FFFFFF}收购产业\n{C3C3C3}查看{FFFFFF}货轮信息", "选择", "取消");
	return 1;
}
CMD:money(playerid, params[])
{
    GivePlayerMoney(playerid, 10000);
    return 1;
}
CMD:createcar(playerid, params[])
{
	new Float:pos[3];
	GetPlayerPos(playerid, pos[0], pos[1], pos[2]);
	new vehicleID = AddStaticVehicleEx(422, pos[0], pos[1], pos[2], 90.0, 1, 1, -1);
	if(vehicleID == INVALID_VEHICLE_ID) return print("无效车辆id");
	vehCargo[vehicleID] = 0;
	cargoType[vehicleID] = 0;
	cargoPrice[vehicleID] = 0;
	return 1;
}

CMD:setdctime(playerid, params[])
{
	KillTimer(servertime);
	SetTimer("refresh_storage", 10000, true);
}

CMD:cargo(playerid, params[])
{
    new type[128], str[128];

	if(sscanf(params, "s[128]", type))
	{
	    if(IsPlayerInAnyVehicle(playerid) || PlayerToCar(playerid, 1, 3.0))
	    {
            ShowCargoList(playerid);
		}
		else if(CarryingCrate[playerid])
		{
			format(str, sizeof(str), "\n \n{C3C3C3}数量\t\t物品\t\t单价\n{FFFFFF}1\t\t%s\t\t$%d", ReturnCargoName(GetPVarInt(playerid, "cargoBType")), GetPVarInt(playerid, "cargoBPrice"));
			return ShowPlayerDialog(playerid, DIALOG_CARGO_LIST, DIALOG_STYLE_MSGBOX, "货物", str, ">>", "");
		}
		SendClientMessage(playerid, -1, "用法: /cargo [内容选项]");
		SendClientMessage(playerid, -1, "可用选项: buy, place, take, drop, pick");
		return 1;
	}
	if(strcmp(type, "buy", true) == 0)
	{
		if(!IsPlayerNearInd(playerid)) return SendClientMessage(playerid, -1, "请靠近该工业区.");
		if(!CarryingCrate[playerid])
		{
		    new IND_ID = GetNearestInd(playerid);
		    if(GetPlayerMoney(playerid) >= Job_Trucker[IND_ID][deliverPrice])
		    {
		        ClearAnimations(playerid);
		        SetPVarInt(playerid, "cargoBType", Job_Trucker[IND_ID][deliverType]);
		        SetPVarInt(playerid, "cargoBPrice", Job_Trucker[IND_ID][deliverPrice]);
                Job_Trucker[IND_ID][deliverStock] -= randomEx(5, 20);
                Job_Trucker[IND_ID][deliverWanted][2] ++;
                
		        ApplyAnimation(playerid, "carry", "liftup", 1, 0, 1, 1, 0, 1000);
		        ApplyAnimation(playerid, "carry", "liftup", 1, 0, 1, 1, 0, 1000);
		        SetPlayerAttachedObject(playerid,9,2912,1,0.035999,0.193999,-0.032000,-91.299919,8.600003,88.300056,0.572999,0.530999,0.587000);
		        CarryingCrate[playerid] = true;
		        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
		        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
		        GivePlayerMoney(playerid, -Job_Trucker[IND_ID][deliverPrice]);
		        Update_Industry_Label(IND_ID);
			}
			else return SendClientMessage(playerid, -1, "你没有足够的钱.");
		}
		else return SendClientMessage(playerid, -1, "请先完成当前操作.");
	}
	else if(strcmp(type, "sell", true) == 0)
	{
		if(!IsPlayerNearInd(playerid)) return SendClientMessage(playerid, -1, "请靠近该工业区.");
		if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SendClientMessage(playerid, -1, "你需要为步行状态!");
        if(!CarryingCrate[playerid]) return SendClientMessage(playerid, -1, "你手上没有箱子.");
        new IND_ID = GetNearestInd(playerid);
        //if(Job_Trucker[IND_ID][deliverStock] < Job_Trucker[IND_ID][deliverWanted][2]) return SendClientMessage(playerid, -1, "当前该园区库存小于需求数量, 无法供应!");
        if(GetPVarInt(playerid, "cargoBType") == Job_Trucker[IND_ID][deliverWanted][0])
        {
            /*if(Job_Trucker[IND_ID][deliverMain] > (Job_Trucker[IND_ID][deliverStock] + Job_Trucker[IND_ID][deliverWanted][2]) / 2)
            {
                Job_Trucker[IND_ID][deliverStock] += Job_Trucker[IND_ID][deliverWanted][2] / 2;
            }
            else
			{
				Job_Trucker[IND_ID][deliverStock] = Job_Trucker[IND_ID][deliverMain];
			}*/
			Job_Trucker[IND_ID][deliverStock] -= Job_Trucker[IND_ID][deliverWanted][2] / 2;
			
            Job_Trucker[IND_ID][deliverWanted][2] --;
		    RemovePlayerAttachedObject(playerid, 9);
		    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
	        CarryingCrate[playerid] = false;
	        GivePlayerMoney(playerid, Job_Trucker[IND_ID][deliverWanted][1]);
	        DeletePVar(playerid, "cargoBType");
	        Update_Industry_Label(IND_ID);
		}
		else if(GetPVarInt(playerid, "cargoBType") == Job_Trucker[IND_ID][deliverType])
		{
		    RemovePlayerAttachedObject(playerid, 9);
		    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
		    Job_Trucker[IND_ID][deliverStock] ++;
		    CarryingCrate[playerid] = false;
		    GivePlayerMoney(playerid, Job_Trucker[IND_ID][deliverPrice]);
		    DeletePVar(playerid, "cargoBType");
		    Update_Industry_Label(IND_ID);
		}
		else return SendClientMessage(playerid, -1, "我们不需要这个物品!");
	}
	else if(strcmp(type, "place", true) == 0)
	{ 
		new vehicleID = PlayerToCar(playerid, 2, 3.0);
		if(vehicleID == INVALID_VEHICLE_ID) return SendClientMessage(playerid, -1, "请靠近该车辆.");
		if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SendClientMessage(playerid, -1, "你需要为步行状态!");
        if(!CarryingCrate[playerid]) return SendClientMessage(playerid, -1, "你手上没有箱子.");
        if(cargoType[vehicleID] != 0 && GetPVarInt(playerid, "cargoBType") != cargoType[vehicleID]) return SendClientMessage(playerid, -1, "该载具已经装载了其他货物, 请先运完."); // 卸货后重置车辆cargoType为0
        if(vehCargo[vehicleID] >= countCargo(vehicleID)) return SendClientMessage(playerid, -1, "该载具已经拥有它所能装载最大数量的货物了.");
	    RemovePlayerAttachedObject(playerid, 9);
	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        CarryingCrate[playerid] = false;
        vehCargo[vehicleID]++;
        cargoPrice[vehicleID] = GetPVarInt(playerid, "cargoBPrice");
        SetCargoOnCar(vehicleID, vehCargo[vehicleID]);
        cargoType[vehicleID] = GetPVarInt(playerid, "cargoBType");
        DeletePVar(playerid, "cargoBType");
        DeletePVar(playerid, "cargoBPrice");
	}
	else if(strcmp(type, "take", true) == 0)
	{
		new vehicleID = PlayerToCar(playerid, 2, 3.0);
		if(vehicleID == INVALID_VEHICLE_ID) return SendClientMessage(playerid, -1, "请靠近该车辆.");
		if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SendClientMessage(playerid, -1, "你需要为步行状态!");
        ClearAnimations(playerid);
        ApplyAnimation(playerid, "carry", "liftup", 1, 0, 1, 1, 0, 1000);
        ApplyAnimation(playerid, "carry", "liftup", 1, 0, 1, 1, 0, 1000);
        SetPlayerAttachedObject(playerid,9,2912,1,0.035999,0.193999,-0.032000,-91.299919,8.600003,88.300056,0.572999,0.530999,0.587000);
        CarryingCrate[playerid] = true;
        SetPVarInt(playerid, "cargoBType", cargoType[vehicleID]);
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
        SetCargoOnCar(vehicleID, vehCargo[vehicleID]);
        vehCargo[vehicleID] -= 1;
	}
	else if(strcmp(type, "drop", true) == 0)
	{
		if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SendClientMessage(playerid, -1, "你需要为步行状态!");
        if(!CarryingCrate[playerid]) return SendClientMessage(playerid, -1, "你手上没有箱子.");
        //if(!IsPlayerNearCrate(playerid) return SendClientMessage(playerid, -1, "附近没有箱子或你离它太远!");
        if(CrateChecker(playerid) >= 2) return SendClientMessage(playerid, -1, "你已经超过最大丢弃数量. (2)");
        //new crateid = GetNearestCrate(playerid);
	    RemovePlayerAttachedObject(playerid, 9);
	    SetPlayerSpecialAction(playerid, SPECIAL_ACTION_NONE);
        CarryingCrate[playerid] = false;
        CreateDroppedCargo(playerid);
	}
	else if(strcmp(type, "pick", true) == 0)
	{
		if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SendClientMessage(playerid, -1, "你需要为步行状态!");
        if(CarryingCrate[playerid]) return SendClientMessage(playerid, -1, "你手上已有箱子.");
        if(!IsPlayerNearCrate(playerid)) return SendClientMessage(playerid, -1, "附近没有箱子或你离它太远!");
        ClearAnimations(playerid);
        ApplyAnimation(playerid, "carry", "liftup", 1, 0, 1, 1, 0, 1000);
        ApplyAnimation(playerid, "carry", "liftup", 1, 0, 1, 1, 0, 1000);
        SetPlayerAttachedObject(playerid,9,2912,1,0.035999,0.193999,-0.032000,-91.299919,8.600003,88.300056,0.572999,0.530999,0.587000);
        CarryingCrate[playerid] = true;
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
        DestroyCrate(playerid);
	}
	else if(strcmp(type, "time", true) == 0)
	{
        if(!IsPlayerNearCrate(playerid)) return SendClientMessage(playerid, -1, "附近没有箱子或你离它太远!");
        new id = GetNearestCrate(playerid);
        dCrates[id][dcExpTime] = 10;
	}
	else
	{
        cmd_cargo(playerid, "");
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(dialogid == DIALOG_TRUCKERPDA)
	{
	    if(!response) return 1;
	    switch(listitem)
	    {
	        case 0: PDA_ALL_Dialog(playerid), SetPVarInt(playerid, "SelectDPoint", listitem);
	        case 1:
	        {
		    	ShowPlayerDialog(playerid, 6666, DIALOG_STYLE_TABLIST_HEADERS, "卡车司机 PDA",
				"产业名称\t收购物品\t单价\t需求数量\n\
				红郡农场\t水果\t$24\t24个\n\
				高山木材厂\t木材\t$63\t52个\n\
				Locals Only\t服装\t$76\t75个\n\
				San Andreas Sheriff's Dept\t军火\t$1250\t22个\n\
				真理快餐店\t猪肉\t$99999\t1个\n\
				中央银行\t鸡蛋\t$1\t1000个",
				"标记", "返回");
	        }
	        case 2:
	        {
		    	ShowPlayerDialog(playerid, 6666, DIALOG_STYLE_MSGBOX, "LV码头 - 货轮编号#6","此货轮已经{FFFF00}到岸{FFFFFF}.\n \n货轮到岸时间: 21:20\n货轮离岸时间: 21:40\n下一批货轮编号: LV#7\n \n{FFFF00}出售物品{FFFFFF}:\n{C3C3C3}该产业不出售任何东西!\n \n{FFFF00}需求物品{FFFFFF}:\n{C3C3C3}物品名称\t\t单价\t\t库存{FFFFFF}\n木材\t\t$631\t\t600 (捆)","标记", "返回");
	        }
	    }
	}
	if(dialogid == DIALOG_MANAGE_IND)
	{
	    if(!response) return 1;
	    switch(listitem)
	    {
		    case 0:
		    {
				Action_IND_Dialog(playerid);
	        }
	        case 1:
	        {

	        }
	        case 2:
	        {
	            if(!IsPlayerNearInd(playerid)) return SendClientMessage(playerid, -1, "你附近没有任何工业区!");

	            new msg[128],
	            	IND_ID = GetNearestInd(playerid);
	            	
	            format(msg, sizeof(msg), "{FFFF00}提示: {FFFFFF}工业区 %d 已从服务器中删除。", IND_ID);
	    		SendClientMessage(playerid, -1, msg);
	    		Remove_Industry(IND_ID);
	        }
	        case 3:
	        {
	        
	        }
	    }
	}
	if(dialogid == DIALOG_ADD_IND)
	{
	    if(!response)
		{
            Action_IND_Dialog(playerid);
			return 1;
		}
	    switch(listitem)
	    {
		    case 0:
		    {
				ShowPlayerDialog(playerid, DIALOG_IND_NAME, DIALOG_STYLE_INPUT, "创建工业区 - 名字", "请输入工业区名称", "确定", "返回");
		    }
		    case 1:
		    {
                ShowPlayerDialog(playerid, DIALOG_IND_TYPE, DIALOG_STYLE_LIST, "创建工业区 - 类型", "水果\n猪肉\n鸡蛋\n服装\n车辆零件\n木材\n军火", "确定", "返回");
		    }
		    case 2:
		    {
		        ShowPlayerDialog(playerid, DIALOG_IND_MAIN, DIALOG_STYLE_INPUT, "创建工业区 - 总库存", "请输入需要设置的总库存\n提示: 请不要超过300件.", "确定", "返回");
		    }
		    case 3:
		    {
		        ShowPlayerDialog(playerid, DIALOG_IND_PRICE, DIALOG_STYLE_INPUT, "创建工业区 - 单价", "请输入需要设置的物品单价\n提示: 请酌情设置!", "确定", "返回");
		    }
		    case 6:
		    {
		        Create_Industry(playerid, GetStringVar(playerid, "editIND_Name"), GetPVarInt(playerid, "type"), GetPVarInt(playerid, "main"), GetPVarInt(playerid, "price"));
		    }
		    case 7:
		    {
				SendClientMessage(playerid, -1, "服务器: 放弃创建工业区.");
		  		DeletePVar(playerid, "editIND_Name");
		  		DeletePVar(playerid, "editIND_Type");
		  		DeletePVar(playerid, "editIND_Price");
		  		DeletePVar(playerid, "editIND_Main");
		  		DeletePVar(playerid, "editIND_Stock");
		    }
	    }
	}
	if(dialogid == DIALOG_IND_NAME)
	{
	    if(!response)
		{
            Action_IND_Dialog(playerid);
			return 1;
		}
		if(!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_IND_NAME, DIALOG_STYLE_INPUT, "创建工业区 - 名字", "请输入工业区名称", "确定", "返回");
		new text[128];
		format(text, sizeof(text), "%s", inputtext);
		SetStringVar(playerid, "editIND_Name", text);
		SendClientMessage(playerid, -1, "服务器: 设置成功进入下一页.");
		ShowPlayerDialog(playerid, DIALOG_IND_TYPE, DIALOG_STYLE_LIST, "创建工业区 - 类型", "日常杂物\n食物\n木材\n服装\n车辆\n加工厂\n军火", "确定", "返回");
	}
	if(dialogid == DIALOG_IND_TYPE)
	{
	    if(!response)
		{
            Action_IND_Dialog(playerid);
			return 1;
		}
		if(!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_IND_TYPE, DIALOG_STYLE_LIST, "创建工业区 - 类型", "日常杂物\n食物\n木材\n服装\n车辆\n加工厂\n军火", "确定", "返回");
		SetPVarInt(playerid, "editIND_Type", listitem+1);
		SendClientMessage(playerid, -1, "服务器: 设置成功进入下一页.");
		ShowPlayerDialog(playerid, DIALOG_IND_MAIN, DIALOG_STYLE_INPUT, "创建工业区 - 总库存", "请输入需要设置的总库存\n提示: 请不要超过300件.", "确定", "返回");
	}
	if(dialogid == DIALOG_IND_MAIN)
	{
	    if(!response)
		{
            Action_IND_Dialog(playerid);
			return 1;
		}
		if(!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_IND_MAIN, DIALOG_STYLE_INPUT, "创建工业区 - 总库存", "请输入需要设置的总库存\n提示: 请不要超过300件.", "确定", "返回");
		if(!NumChecker(inputtext)) return ShowPlayerDialog(playerid, DIALOG_IND_MAIN, DIALOG_STYLE_INPUT, "创建工业区 - 总库存", "请输入需要设置的总库存\n提示: 请输入数字.", "确定", "返回");
		if(strval(inputtext) > 300 || strval(inputtext) < 150) return ShowPlayerDialog(playerid, DIALOG_IND_MAIN, DIALOG_STYLE_INPUT, "创建工业区 - 总库存", "请输入需要设置的总库存\n错误: 请输入150-300之间的数字.", "确定", "返回");
		SetPVarInt(playerid, "editIND_Main", strval(inputtext));
		SendClientMessage(playerid, -1, "服务器: 设置成功进入下一页.");
		ShowPlayerDialog(playerid, DIALOG_IND_PRICE, DIALOG_STYLE_INPUT, "创建工业区 - 单价", "请输入需要设置的物品单价\n提示: 请酌情设置!", "确定", "返回");
	}
	if(dialogid == DIALOG_IND_PRICE)
	{
	    if(!response)
		{
            Action_IND_Dialog(playerid);
			return 1;
		}
		if(!strlen(inputtext)) return ShowPlayerDialog(playerid, DIALOG_IND_PRICE, DIALOG_STYLE_INPUT, "创建工业区 - 单价", "请输入需要设置的物品单价\n提示: 请酌情设置!", "确定", "返回");
		if(!NumChecker(inputtext)) return ShowPlayerDialog(playerid, DIALOG_IND_PRICE, DIALOG_STYLE_INPUT, "创建工业区 - 单价", "请输入需要设置的物品单价\n错误: 请输入数字!", "确定", "返回");
		if(strval(inputtext) > 1000 || strval(inputtext) < 5) return ShowPlayerDialog(playerid, DIALOG_IND_PRICE, DIALOG_STYLE_INPUT, "创建工业区 - 单价", "请输入需要设置的物品单价\n错误: 请输入5-1000之内的价格!", "确定", "返回");
		SetPVarInt(playerid, "editIND_Price", strval(inputtext));
		SendClientMessage(playerid, -1, "服务器: 设置成功进入下一页.");
		ShowPlayerDialog(playerid, DIALOG_IND_STOCK, DIALOG_STYLE_MSGBOX, "创建工业区", "是否确认创建该工业区?", "确定", "取消");
	}
	if(dialogid == DIALOG_IND_STOCK)
	{
	    if(response)
		{
            Create_Industry(playerid, GetStringVar(playerid, "editIND_Name"), GetPVarInt(playerid, "editIND_Type"), GetPVarInt(playerid, "editIND_Main"), GetPVarInt(playerid, "editIND_Price"));
		}
		else
		{
			SendClientMessage(playerid, -1, "服务器: 放弃创建工业区.");
	  		DeletePVar(playerid, "editIND_Name");
	  		DeletePVar(playerid, "editIND_Type");
	  		DeletePVar(playerid, "editIND_Price");
	  		DeletePVar(playerid, "editIND_Main");
	  		DeletePVar(playerid, "editIND_Stock");
		}
	}
	if(dialogid == DIALOG_PDA_SEL)
	{
	    if(response)
		{
            SetPVarInt(playerid, "SelectDPoint", listitem);
            PDA_SEL_Dialog(playerid);
		}
		else
		{
		    DeletePVar(playerid, "SelectDPoint");
		}
	}
	if(dialogid == DIALOG_CARGO_LIST)
	{
	    if(response)
	    {
			new vehicleID = PlayerToCar(playerid, 2, 3.0);
			if(vehicleID == INVALID_VEHICLE_ID) return SendClientMessage(playerid, -1, "请靠近该车辆.");
			if(GetPlayerState(playerid) != PLAYER_STATE_ONFOOT) return SendClientMessage(playerid, -1, "你需要为步行状态!");
	        ClearAnimations(playerid);
	        SetPVarInt(playerid, "cargoBType", cargoType[vehicleID]);
	        ApplyAnimation(playerid, "carry", "liftup", 1, 0, 1, 1, 0, 1000);
	        ApplyAnimation(playerid, "carry", "liftup", 1, 0, 1, 1, 0, 1000);
	        SetPlayerAttachedObject(playerid,9,2912,1,0.035999,0.193999,-0.032000,-91.299919,8.600003,88.300056,0.572999,0.530999,0.587000);
	        CarryingCrate[playerid] = true;
	        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
	        SetPlayerSpecialAction(playerid, SPECIAL_ACTION_CARRY);
	        SetCargoOnCar(vehicleID, vehCargo[vehicleID]);
	        vehCargo[vehicleID] -= 1;
	    }
	}
	return 1;
}

stock Create_Industry(playerid, name[], type, main, price)
{
	new string[20],
		ID = row_industry(),
		labeldesc[300],
		Float:player_Pos[3];

	if(ID >= 0)
	{
	    format(string, sizeof(string), DELIVERY_FOLDER, ID);
	    dini_Create(string);
		GetPlayerPos(playerid, player_Pos[0], player_Pos[1], player_Pos[2]);
		Job_Trucker[ID][deliverID] = ID;
		format(Job_Trucker[ID][deliverName], 128, name);
		Job_Trucker[ID][deliverX] = player_Pos[0];
	   	Job_Trucker[ID][deliverY] = player_Pos[1];
	    Job_Trucker[ID][deliverZ] = player_Pos[2];
	    Job_Trucker[ID][deliverPrice] = price;
	    Job_Trucker[ID][deliverType] = type;
	    Job_Trucker[ID][deliverMain] = main;
	    Job_Trucker[ID][deliverStock] = main;
	    Job_Trucker[ID][deliverRun] = 1;
		format(labeldesc, sizeof(labeldesc), "[{FFFF00}%s{FFFFFF}]\n{C3C3C3}库存: %d / %d\n价格: $%d / 单件", name, main, main, price);
		Job_Trucker[ID][deliverLabel] = CreateDynamic3DTextLabel(labeldesc, -1, player_Pos[0], player_Pos[1], player_Pos[2]+1.0, 30.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 100.0);
		Job_Trucker[ID][deliverPickup] = CreateDynamicPickup(1318, 1, player_Pos[0], player_Pos[1], player_Pos[2], 0, -1, -1, 30.0);
		countDPoint ++;
		SaveDPoint();
		SendClientMessage(playerid, -1, "工业区创建成功");
	}
	else
	{
	    SendClientMessage(playerid, -1, "无法创建更多的工业区了");
	    printf("[控制台] >> 无法创建工业区文件, 尝试地址: /trucker/%d.ini!", ID);
	}
	return 1;
}

stock IsPlayerNearInd(playerid)
{
	for(new i = 0; i != MAX_D_POINT; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 5.0, Job_Trucker[i][deliverX], Job_Trucker[i][deliverY], Job_Trucker[i][deliverZ]))
		{
		    if(Job_Trucker[i][deliverID] == -1) return 0;
			return 1;
		}
	}
	return 0;
}
stock GetNearestInd(playerid)
{
    for(new b = 0; b < MAX_D_POINT; b++)
    {
        if(Job_Trucker[b][deliverID] != -1)
		{
		    if(IsPlayerInRangeOfPoint(playerid, 5.0, Job_Trucker[b][deliverX], Job_Trucker[b][deliverY], Job_Trucker[b][deliverZ]))
		    {
      			return Job_Trucker[b][deliverID];
		    }
        }
    }
    return 0;
}
stock Remove_Industry(IND_ID)
{  // 如果玩家在运送这个地方, 就重置并且提示给他... 另外补偿点钱... 或者是他可以去其他地方卖
	new string[128];
	format(string, sizeof(string),"/trucker/%d.ini", IND_ID);
	if(dini_Exists(string))
	{
		Job_Trucker[IND_ID][deliverID] = -1;
		format(Job_Trucker[IND_ID][deliverName], 128, "None");
		Job_Trucker[IND_ID][deliverX] = 0.0;
	   	Job_Trucker[IND_ID][deliverY] = 0.0;
	    Job_Trucker[IND_ID][deliverZ] = 0.0;
	    Job_Trucker[IND_ID][deliverPrice] = 0;
	    Job_Trucker[IND_ID][deliverType] = 0;
	    Job_Trucker[IND_ID][deliverMain] = 0;
	    Job_Trucker[IND_ID][deliverStock] = 0;
	    Job_Trucker[IND_ID][deliverRun] = 0;
	    printf("[控制台] >> %d号工业区从文件中删除!", IND_ID);
	    DestroyDynamic3DTextLabel(Job_Trucker[IND_ID][deliverLabel]);
	    DestroyDynamicPickup(Job_Trucker[IND_ID][deliverPickup]);
	    dini_Remove(string);
	}
	else
	{
	    printf("[控制台] >> 无法找到文件, 地址: /trucker/%d.ini!", IND_ID);
	}
	return 1;
}
stock Update_Industry(playerid, IND_ID, temp_price, temp_type, temp_main, temp_stock, temp_status)
{
	new
		labeldesc[300],
		Float:player_Pos[3];
		
	GetPlayerPos(playerid, player_Pos[0], player_Pos[1], player_Pos[2]);
    Job_Trucker[IND_ID][deliverPrice] = temp_price;
    Job_Trucker[IND_ID][deliverType] = temp_type;
    Job_Trucker[IND_ID][deliverMain] = temp_main;
    Job_Trucker[IND_ID][deliverStock] = temp_stock;
    Job_Trucker[IND_ID][deliverRun] = temp_status;

	DestroyDynamic3DTextLabel(Job_Trucker[IND_ID][deliverLabel]);
 	DestroyDynamicPickup(Job_Trucker[IND_ID][deliverPickup]);
 	
	format(labeldesc, sizeof(labeldesc), "[{FFFF00}%s{FFFFFF}]\n{C3C3C3}库存: %d / %d\n价格: $%d / 单件", name, stock, main, price);
	Job_Trucker[IND_ID][deliverLabel] = CreateDynamic3DTextLabel(labeldesc, -1, player_Pos[0], player_Pos[1], player_Pos[2]+1.0, 30.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 100.0);
	Job_Trucker[IND_ID][deliverPickup] = CreateDynamicPickup(1318, 1, player_Pos[0], player_Pos[1], player_Pos[2], 0, -1, -1, 30.0);
	return 1;
}
stock Update_Industry_Label(IND_ID)
{
	new labeldesc[300];
	//DestroyDynamic3DTextLabel(Job_Trucker[IND_ID][deliverLabel]);
 	//DestroyDynamicPickup(Job_Trucker[IND_ID][deliverPickup]);
	format(labeldesc, sizeof(labeldesc), "[{FFFF00}%s{FFFFFF}]\n{C3C3C3}库存: %d / %d\n价格: $%d / 单件", Job_Trucker[IND_ID][deliverName], Job_Trucker[IND_ID][deliverStock], Job_Trucker[IND_ID][deliverMain], Job_Trucker[IND_ID][deliverPrice]);
    UpdateDynamic3DTextLabelText(Job_Trucker[IND_ID][deliverLabel], -1, labeldesc);
}
Action_IND_Dialog(playerid)
{
    new str[512], type[48];
	if(GetPVarInt(playerid, "editIND_Type") == 0) format(type, 48, "未设置");
	else if(GetPVarInt(playerid, "editIND_Type") == 1) format(type,48,"水果");
	else if(GetPVarInt(playerid, "editIND_Type") == 2) format(type,48,"猪肉");
	else if(GetPVarInt(playerid, "editIND_Type") == 3) format(type,48,"鸡蛋");
	else if(GetPVarInt(playerid, "editIND_Type") == 4) format(type,48,"服装");
	else if(GetPVarInt(playerid, "editIND_Type") == 5) format(type,48,"车辆零件"); // 需要一台运送车辆的train truck, 价格80W一台 跑一次差不多几千块钱
	else if(GetPVarInt(playerid, "editIND_Type") == 6) format(type,48,"木材"); // 运送加工材料，给组织使用
	else if(GetPVarInt(playerid, "editIND_Type") == 7) format(type,48,"军火"); // 需要组织权限并且政府组织需要这个才能得到武器

    format(str, sizeof(str), "工业区名字: %s\n经营类型: %s\n总货数: %d\n单品价格: $%d\n \n \n创建工业区\n放弃创建", GetStringVar(playerid, "editIND_Name"), type, GetPVarInt(playerid, "editIND_Main"), GetPVarInt(playerid, "editIND_Price"));
	ShowPlayerDialog(playerid, DIALOG_ADD_IND, DIALOG_STYLE_LIST, "创建工业区", str, "选择", "");
}

stock ShowCargoList(playerid)
{
	new carid = 0, gString[256];
	if(IsPlayerInAnyVehicle(playerid)) carid = GetPlayerVehicleID(playerid);
		else carid = PlayerToCar(playerid, 2, 3.0);

    if(vehCargo[carid] == 0) return ShowPlayerDialog(playerid, 6666, DIALOG_STYLE_MSGBOX, "车辆货物", "该载具没有装载货物..", "<<", "");
	new price = cargoPrice[carid] * vehCargo[carid];
	new name[35];
	GetVehicleName(carid, name);
	format(gString, sizeof(gString), "物流车辆: {FFFF00}%s\n \n{C3C3C3}数量\t\t物品\t\t总价值\n{FFFFFF}%d\t\t%s\t\t$%d", name, vehCargo[carid], ReturnCargoName(cargoType[carid]), price);
	return ShowPlayerDialog(playerid, DIALOG_CARGO_LIST, DIALOG_STYLE_MSGBOX, "车辆货物", gString, "卸货", "<<");
}

PDA_ALL_Dialog(playerid) // 列出所有
{
   	new count = 0, gString[3000], isrun[128], helpstr[1600];
 	for(new i = 0; i < MAX_D_POINT; i ++)
 	{
 	    if(Job_Trucker[i][deliverID] == 0 || Job_Trucker[i][deliverID] == -1) continue;
		switch(Job_Trucker[i][deliverRun])
		{
			case 0: isrun = "{FF6347}空仓";
			case 1: isrun = "{FFFF00}收购";
		}
	    count++;
		format(gString, sizeof(gString), "%s ({C3C3C3}%s, %s{FFFFFF})\n", Job_Trucker[i][deliverName], ReturnCargoName(Job_Trucker[i][deliverType]), isrun);
	 	strcat(helpstr, gString);
	}
	if(count <= 0) return ShowPlayerDialog(playerid, 6666, DIALOG_STYLE_MSGBOX, "目前政府还没有开发工业区..", helpstr, "<<", "");
	ShowPlayerDialog(playerid, DIALOG_PDA_SEL, DIALOG_STYLE_LIST, "卡车司机PDA - 所有工业区", helpstr, "选择", "返回");
	return 1;
}

PDA_SEL_Dialog(playerid)
{
   	new gString1[3000],
	   isrun1[128],
	   title[64],
	   returnid = GetPVarInt(playerid, "SelectDPoint")+1,
	   helpstr1[1600];

	switch(Job_Trucker[returnid][deliverRun])
	{
		case 0: isrun1 = "{FF6347}空仓";
		case 1: isrun1 = "{FFFF00}收购";
	}
    format(title, sizeof(title), "%s", Job_Trucker[returnid][deliverName]);
	format(gString1, sizeof(gString1), "工业区状态: %s{FFFFFF}!\n \n{FFFF00}出售物品\n{C3C3C3}名称\t\t价格(单个)\t\t库存\n{FFFFFF}%s\t\t$%d\t\t%d\n \n{FFFF00}收购物品\n{C3C3C3}名称\t\t价格(单个)\t\t需求数量\n{FFFFFF}%s\t\t$%d\t\t%d\n", isrun1, ReturnCargoName(Job_Trucker[returnid][deliverType]), Job_Trucker[returnid][deliverPrice], Job_Trucker[returnid][deliverStock], ReturnCargoName(Job_Trucker[returnid][deliverWanted][0]), Job_Trucker[returnid][deliverWanted][1], Job_Trucker[returnid][deliverWanted][2]);
 	strcat(helpstr1, gString1);
	ShowPlayerDialog(playerid, 6666, DIALOG_STYLE_MSGBOX, title, helpstr1, "设置路线", "返回");
}

stock SetStringVar(playerid, varname[], value[])
{
	return SetPVarString(playerid, varname, value);
}

stock GetStringVar(playerid, varname[])
{
	new str[256];
	GetPVarString(playerid, varname, str, sizeof(str));
	return str;
}
NumChecker(const string[])
{
	for(new i = 0, j = strlen(string); i < j; i++)
	{
 		if(string[i] > '9' || string[i] < '0') return 0;
	}
	return 1;
}
ReturnCargoName(id)
{
	new str[48];
	switch(id)
	{
		case 1: str = "水果";
		case 2: str = "猪肉";
		case 3: str = "鸡蛋";
		case 4: str = "服装";
		case 5: str = "车辆零件";
		case 6: str = "木材";
		case 7: str = "军火";
		default: str = "未知";
	}
	return str;
}
session_refresh_storage(IND_ID)//补货
{
	countTimer++;
	if(countTimer >= 3)
		countTimer = 0;
		
	//if(Job_Trucker[IND_ID][deliverMain] - Job_Trucker[IND_ID][deliverStock] > 20) return printf("[控制台] >> %d 跳过", IND_ID);
	Job_Trucker[IND_ID][deliverStock] += floatround(Job_Trucker[IND_ID][deliverMain] / 2) * 0.5;
 	printf("[控制台] >> %d 已补充 %d 个货物.", IND_ID, Job_Trucker[IND_ID][deliverStock]);
	return 1;
}
stock PlayerToCar(playerid,type,Float:distance) {
    new Float:x, Float:y, Float:z, Float:closedist, id = -1;
    foreach(new c : Vehicle)
	{
        if(IsVehicleStreamedIn(c, playerid)) {
			GetVehiclePos(c,x,y,z);
			new Float:dist = GetPlayerDistanceFromPoint(playerid, x, y, z);
			if(!closedist) {
				closedist = dist;
				id = c;
			} else {
				if(dist < closedist) {
					closedist = dist;
					id = c;
				}
			}
		}
    }
	if(id != -1) {
		GetVehiclePos(id,x,y,z);
		if(IsPlayerInRangeOfPoint(playerid,distance,x,y,z)) {
			switch(type) {
				case 1: return true;
				case 2: return id;
			}
		}
	}
	if(type == 1) return false;
    return INVALID_VEHICLE_ID;
}
forward countCargo(veh); 
public countCargo(veh)
{

	new modelid = GetVehicleModel(veh), count;
	switch(modelid)
	{
	    case 422: count = 3; // bobcat 手拿
	    case 554: count = 4; // yosemite 手拿 1
	    case 443: count = 2; // Packer 装载
		case 578: count = 1; // DFT-30 装载 1
		case 543: count = 2; // Sadler 手拿 1
		case 478: count = 5; // Walton 手拿 水果
		case 584: count = MAX_CARGOS; // petrol trailer 油罐车 车库装载
		case 455: count = 2; // Flatbed 手拿 木材 1
	}
	return count;
}
forward SetCargoOnCar(car, type);
public SetCargoOnCar(car, type) // 同样模型ID
{
    if(IsValidDynamicObject(VehicleObject[car][type])) return DestroyDynamicObject(VehicleObject[car][type]);
    new modelid = GetVehicleModel(car);
	switch(modelid)
	{
	    case 422: // bobcat
	    {
	        switch(type)
	        {
	            case 1: VehicleObject[car][type] = CreateDynamicObject(2912,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, -0.439, -0.810, -0.290, 0.000, 0.000, 0.000);
	            case 2: VehicleObject[car][type] = CreateDynamicObject(2912,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, 0.439, -0.810, -0.290, 0.000, 0.000, 0.000); // 第一排右箱子 bobcat
	            case 3: VehicleObject[car][type] = CreateDynamicObject(2912,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, -0.439, -1.620, -0.290, 0.000, 0.000, 0.000); // 第二排左箱子 bobcat
	            /*case 3: VehicleObject[car][type] = CreateDynamicObject(2912,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0),AttachDynamicObjectToVehicle(VehicleObject[car][type], car, 0.439, -1.620, -0.290, 0.000, 0.000, 0.000);*/
	        }
	    }
	    case 578://dft-30
	    {
	        switch(type)
	        {
	            default: VehicleObject[car][type] = CreateDynamicObject(3571,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, 0.000000,-1.800000,1.049999,0.000000,0.000000,89.099983);
	        }
	    }
	    case 554: // Yosemite
	    {
	        switch(type)
	        {
	            case 1: VehicleObject[car][type] = CreateDynamicObject(2912,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, -0.300000,-1.350000,-0.225000,0.000000,0.000000,0.000000);
	            case 2: VehicleObject[car][type] = CreateDynamicObject(2912,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, 0.449999,-1.350000,-0.225000,0.000000,0.000000,0.000000);
	            case 3: VehicleObject[car][type] = CreateDynamicObject(2912,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, 0.449999,-2.175000,-0.225000,0.000000,0.000000,0.000000);
	            case 4: VehicleObject[car][type] = CreateDynamicObject(2912,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, -0.300000,-2.175000,-0.225000,0.000000,0.000000,0.000000);
	        }
	    }
	    case 455:
	    {
	        switch(type)
	        {
	            case 1: VehicleObject[car][type] = CreateDynamicObject(18609,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, -0.150000,1.049999,1.200000,0.000000,-0.000001,183.599884);
	            case 2: VehicleObject[car][type] = CreateDynamicObject(18609,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, -0.150000,1.049999,1.875000,0.000000,-0.000001,183.599884);
	        }
	    }
	    case 443:
	    {
	        switch(type)
	        {
	            case 1: VehicleObject[car][type] = CreateDynamicObject(3593,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, -0.000000,0.300000,1.725000,16.200000,0.000000,0.000000);
	            case 2: VehicleObject[car][type] = CreateDynamicObject(3593,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, 0.074999,-6.449995,-0.074999,16.200000,0.000000,0.000000);
	        }
	    }
	    case 543:
	    {
	        switch(type)
	        {
	            case 1: VehicleObject[car][type] = CreateDynamicObject(2912,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, -0.300000,-0.899999,-0.150000,0.000000,0.000000,0.000000);
	            case 2: VehicleObject[car][type] = CreateDynamicObject(2912,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, 0.225000,-1.650000,-0.150000,0.000000,0.000000,0.000000);
	        }
	    }
	    case 478:
	    {
	        switch(type)
	        {
	            case 1: VehicleObject[car][type] = CreateDynamicObject(19636,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, 0.000000,-1.350000,-0.074999,0.000000,0.000000,0.000000);
	            case 2: VehicleObject[car][type] = CreateDynamicObject(19636,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, -0.599999,-0.974999,-0.074999,0.000000,0.000000,0.000000);
	            case 3: VehicleObject[car][type] = CreateDynamicObject(19636,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, -0.599999,-1.950000,-0.074999,0.000000,0.000000,0.000000);
	            case 4: VehicleObject[car][type] = CreateDynamicObject(19636,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, 0.599999,-1.650000,-0.074999,0.000000,0.000000,0.000000);
	            case 5: VehicleObject[car][type] = CreateDynamicObject(19636,0.0,0.0,-1000.0,0.0,0.0,0.0,-1,-1,-1,300.0,300.0), AttachDynamicObjectToVehicle(VehicleObject[car][type], car, 0.000000,-1.875000,0.000000,0.000000,0.000000,91.799980);
	        }
	    }
	}
	return 1;
}
stock randomEx(min, max)
{
    new rand = random(max-min)+min;
    return rand;
}
stock CrateChecker(playerid) // 检测玩家是否能丢弃
{
   	new count = 0;
	new name[MAX_PLAYER_NAME];
 	GetPlayerName(playerid,name,sizeof(name));
 	for(new i = 0; i < MAX_DROPPED_CRATE; i ++)
 	{
 	    if(strcmp(dCrates[i][crateOwner], name, false) == 0 && dCrates[i][dcID] > 0) count ++;
	}
	return count;
}
stock CreateDroppedCargo(playerid)
{
	new
		Float:tempPos[3],
		str[128],
		type = GetPVarInt(playerid, "cargoBType"),
		price = GetPVarInt(playerid, "cargoBPrice");
		
	new name[MAX_PLAYER_NAME];
 	GetPlayerName(playerid,name,sizeof(name));
	format(str, sizeof(str), "%s", ReturnCargoName(type));
	GetPlayerPos(playerid, tempPos[0], tempPos[1], tempPos[2]);
	for(new i = 0; i != MAX_DROPPED_CRATE; i++)
	{
		if(dCrates[i][dcID] == 0)
		{
			dCrates[i][dcObject] = CreateDynamicObject(1271, tempPos[0]+1.0, tempPos[1], tempPos[2]-0.75, 0.0, 0.0, 0.0, -1, -1, -1, 300.0, 300.0);
			//dCrates[i][dcObject] = CreateDynamicObject(2912, tempPos[0]+1.0, tempPos[1], tempPos[2]-1.175, 0.0, 0.0, 0.0, -1, -1, -1, 300.0, 300.0); // 这个OBJ会移动 即是微调
			dCrates[i][dcText] = CreateDynamic3DTextLabel(str, -1, tempPos[0]+1.0, tempPos[1], tempPos[2]+0.15, 30.0, INVALID_PLAYER_ID, INVALID_VEHICLE_ID, 1, -1, -1, -1, 100.0);
			dCrates[i][dcID] = i;
			format(dCrates[i][crateOwner], MAX_PLAYER_NAME, name);
			dCrates[i][dcPos][0] = tempPos[0];
			dCrates[i][dcPos][1] = tempPos[1];
			dCrates[i][dcPos][2] = tempPos[2];
			dCrates[i][dcType] = type;
			dCrates[i][dcPrice] = price;
            dCrates[i][dcExpTime] = 300;
	        DeletePVar(playerid, "cargoBType");
	        DeletePVar(playerid, "cargoBPrice");
            return 1;
		}
	}
	return SendClientMessage(playerid, -1, "服务器箱子数量已达到上限!");
}

stock DestroyCrate(playerid)
{
	new name[MAX_PLAYER_NAME];
 	GetPlayerName(playerid,name,sizeof(name));
 	new crate_id = GetNearestCrate(playerid);
    SetPVarInt(playerid, "cargoBType", dCrates[crate_id][dcType]);
    SetPVarInt(playerid, "cargoBPrice", dCrates[crate_id][dcPrice]);
    
    if(IsValidDynamicObject(dCrates[crate_id][dcObject])) DestroyDynamicObject(dCrates[crate_id][dcObject]);
    if(IsValidDynamic3DTextLabel(dCrates[crate_id][dcText])) DestroyDynamic3DTextLabel(dCrates[crate_id][dcText]);
    printf("[控制台] >> 箱子 %d 被 %s 捡起, 自动清空缓存.", dCrates[crate_id][dcID], name);
	dCrates[crate_id][dcID] = -1;
	format(dCrates[crate_id][crateOwner], MAX_PLAYER_NAME, "None");
	dCrates[crate_id][dcPos][0] = 0.0;
	dCrates[crate_id][dcPos][1] = 0.0;
	dCrates[crate_id][dcPos][2] = 0.0;
	dCrates[crate_id][dcType] = -1;
	dCrates[crate_id][dcPrice] = -1;
    dCrates[crate_id][dcExpTime] = 0;
}

stock IsPlayerNearCrate(playerid)
{
	for(new i = 0; i != MAX_DROPPED_CRATE; i++)
	{
		if(IsPlayerInRangeOfPoint(playerid, 5.0, dCrates[i][dcPos][0], dCrates[i][dcPos][1], dCrates[i][dcPos][2]))
		{
		    if(dCrates[i][dcID] == -1) return 0;
			return 1;
		}
	}
	return 0;
}

stock GetNearestCrate(playerid)
{
    for(new b = 0; b < MAX_DROPPED_CRATE; b++)
    {
        if(dCrates[b][dcID] > 0)
		{
		    if(IsPlayerInRangeOfPoint(playerid, 5.0, dCrates[b][dcPos][0], dCrates[b][dcPos][1], dCrates[b][dcPos][2]))
		    {
		        printf("GetNearestCrate: %d", b);
      			return dCrates[b][dcID];
		    }
        }
    }
    return 0;
}
