#define MAX_CHEMICAL 10
#define MAX_DRUGS    30

enum DRUG_DATA
{
	UID,
	NAME[129],
	TYPE, // 1 health, 2 armour 3 decreas incoming damage 4 invisible for a couple seconds or run fast (play anmation when they run)
	CODE[64],
	CONTROL, // 1 heating 2 cooling
    POINT, // Need x melting / cooling point to finish
    STATUS // 0 labile 1 stable
};

/*
If it's a labile chemical, when they made a wrong step, black smoke will be actived, and if they don't have gas mask

they will be faded away.
*/
new E_CHEMICAL[][DRUG_DATA] =
{
    {0, "Red Phosphorus", 1, "2P2O5", 1, 200, 0},
    {1, "Methylbenzyl-ketone", 1, "C9H10O", 1, 216, 0},
    {2, "Methylenedioxy", 1, "C7H6O2", 1, 172, 0},
    {3, "Heliotropin", 1, "C8H6O3", 2, 120, 1},
    {4, "Ephedrine", 2, "C10H15NO", 1, 37, 1},
    {5, "Phenylacetic Acid", 2, "C8H8O2", 1, 265, 0},
    {6, "Mineral Chameleon", 3, "KMnO4", 1, 240, 1},
    {7, "Chloroform", 3, "CHCl3", 1, 61, 1},
    {8, "Aether", 4, "C4H10O", 1, 160, 0} // if this chemical's point over 160 > 3 seconds and amount > 3mg it will explode
};

enum P_CHEMICALDATA
{
	insertID,
	ChemicalID,
	Float: Amount,
	Owner,
	bool:Selected
};
new P_CHEMICAL[MAX_PLAYERS][MAX_CHEMICAL][P_CHEMICALDATA];

enum P_DRUGS_DATA
{
	drugID,
	Name[128],
	Owner,
	CAS[29], //
	Type, // 1 health, 2 armour 3 decreas incoming damage 4 invisible for a couple seconds or run fast (play anmation when they run)
	Float: Amount, //
	Float: Quality, //
	EffectTime, // what amount they get high on it
	Addiction, // what amount to be addicted
	Creator[128] // the guy who made this drug but it will have his first letter with random string
}
new P_DRUGS[MAX_PLAYERS][MAX_DRUGS][P_DRUGS_DATA];

/*
WORK TYPE:

1 - Dryer
2 - Centrifuge
3 - Mixer
4 - Reactor
5 - Dehydrater
6 - Pickup pump

*/
enum BreakingBadData
{
    temp_ID,
	bool:IsWorking,
    WorkType,
    HouseID,
    NeedTime,
    Working,
    Material,
    Float: Amount,
    Float: Quality,
    Extra[3],
    Type,
    Float: Temperature,
    Float: curTemperature,
    Timer,
    OverPoint,
    Float: Degree,
    Control, // heating / cooling
    BeingCrystal,
    Text3D:osLabel
}
new Chemistry[MAX_FURNITURE][BreakingBadData];
