#include <stdio.h>
#include <string.h>
#define RED "\x1B[31m"
#define BLU "\x1B[34m"
#define GRN "\x1B[32m"
#define YEL "\x1B[33m"
#define MAG "\x1B[35m"
#define CYN "\x1B[36m"
#define RESET "\x1B[0m"


enum State {Q0, O0, O1, O2, O3, O4, O5, O6, I0, I1, F0, F1, F2, V0, S0, S1, S2, C0, C1,\
       	E0, E1, E2, E3, E4, E5, E6, E7, E8, E9, GOOD, FOUND, BAD};
typedef enum State State;

char ch;
FILE *fp;
FILE *fo;

int counter;	// metritis xaraktirwn tou token pou skanaretai
int lcounter;	// metritis grammwn
int token;	// arithmos poy dilonei ton typo tou token (px. 1 gia OPERATOR, 2 gia INTEGER klp)
int uncharflag;	// flag pou sygxronizei thn ektyposi tou [Fatal error] gia agnostous xaraktires, etsi wste na ektyponetai mia fora
int delimflag;	// flag gia ton delimiter mesa se strings. pros to paron douleuei mono gia ta mono kai dipla eisagogika
int goodtokens, badtokens; // metrites gia ta swsta kai lathos tokens

// Pinakas prosorinis apothikefsis tou token pou skanaretai. Ypothetoume oti einai mexri 100 xaraktires.
char tokentmp[100];

// Pinakas kratimenwn leksewn.
static char *keptwords[7]={"len","type","input","print","int","float","str"};

// Synartisi debugging
void dbg(char *prn)
{
//	printf("%s", prn);
}

// Synartisi pou tsekarei an mia metavliti exei onoma kratimenis leksis
int chkvar(char *var)
{
	int k;
	for (k=0;k<=6;k++)
		if(!strcmp(var,keptwords[k]))
			return 1;
	return 0;
}

void scanner();

// O sygkekrimenos lektikos analyths ektyponei STO TERMINAL plirofories sti morfi:
// token	<token_type> (num_of_chars) (line_number)
//
// An energopoihthei h synartisi dbg ektyponei perisoteres plirofories gia tin diadikasia scanning
// Epishs ektyponei ta comments kai ta sfalmata.
//
// Sto arxeio output.txt apothikevontai MONO ta GOOD tokens (ektos apo ta comments) se morfi:
// TOKENTYPE	token

int main(int argc, char** argv)
{
	fp=fopen("./input.txt","r");
	fo=fopen("./output.txt","w");
	if (fp==NULL) return 1;

	lcounter=1;
	goodtokens=0;
	badtokens=0;
	ch=fgetc(fp);

	while (ch!=EOF)
	{
		// Skipping whites
		if(ch==' '||ch=='\n'||ch=='\t')
		{
			if(uncharflag==1){uncharflag=0;printf("\n");}
			dbg("Skipping White Spaces\n");
			while (ch==' '||ch=='\n'||ch=='\t')
			{
				if (ch=='\n'){lcounter++;} // An vrei nea grammi ayksanei ton metriti grammwn kata 1
				ch=fgetc(fp);
			}
		}
		// Start scanning if you find a valid token character
		else if ((ch>='0'&&ch<='9')||(ch>='a'&&ch<='z')||(ch>='A'&&ch<='Z')||ch=='+'||ch=='-'||ch=='*'||ch=='/'||ch=='%'||ch=='='||ch=='.'||ch=='_'||ch=='\''||ch=='\"'||ch=='#')
		{
			if(uncharflag==1){uncharflag=0;printf("\n");}
			scanner(); continue;
		}
		// Special mini-Python characters
		else if (ch==';'||ch==','||ch=='('||ch==')'||ch=='['||ch==']'||ch=='{'||ch=='}')
		{
			if(uncharflag==1){uncharflag=0;printf("\n");}
			goodtokens++;
			printf("%c\t<SPECIAL> (line:%d)\n",ch,lcounter);
			fprintf(fo,"SPECIAL\t\t%c\n",ch);
			ch=fgetc(fp);
		}
		// Unknown characters
		// den paraleipei olokliri thn leksh mexri na vrei white space, alla mono ton agnosto xaraktira
		// an oi agnostoi xaraktires einai synexomenoi tous anagnorizei san 1 lathos, enw an paremvalontai apo egkyro token san 2 ksexorista
		else
		{
			if(uncharflag==0){printf(RED "[Fatal Error] Unknown Characters: (line:%d): " RESET,lcounter);badtokens++;}
			uncharflag=1;
			printf("%c",ch);
			ch=fgetc(fp);
		}
	}
	printf("\n" MAG "FOUND:" RESET GRN " %d Good Tokens" RESET " and " RED "%d Syntax Errors" RESET "\n",goodtokens,badtokens);
	fclose(fp);
	fclose(fo);
	return 0;
}

void scanner()
	// H synartisi scanner prosomoionei ton olokliromeno pinaka metavasis me ta antistoixa cases.
	// 
	// H eisodos stin scanner simenei oti mporei na vgei opoiodipote GOOD token pou exoume orisei na anagnorizetai, 
	// xwris na lamvanei ypopsin an ayto pou prohgeitai h' epetai einai egkyro h' oxi.
	// px stin periptosi '95varname' den tha anagnorisei BAD token metavlitis, alla enan akeraio 95 kai mia metavliti varname.
	// h' px an exoume x=.6-9.e+8 tha anagnorisei tin metavliti x, ton operator = kai dyo float: ton .6 kai ton -9.e+8
	// Ypothetoume oti o syntaktikos analyths tha anagnorisei stin proti periptosi to fatal error
	// kai stin deyteri oti o operator gia tin afairesh einai to prosimo tou deyterou float.
	//
	// Merikes diafores einai oti den ypostirizontai ellinikoi xaraktires, kai oti sta strings yparxei h periptosi tou delimiter
	// opou an diavastei mesa se string allazei tin shmasia tou epomenou xarakthra.
	// Stin sygkekrimeni periptosi xrhsimopoieitai mono gia na akyrosei ta mona h' dipla eisagogika 
	// wste na mporoun na symperilifthoun mesa se string.
	//
	// Telos otan vgainei me katastash GOOD, dinei stin metavliti token ton antistoixo arithmo gia tin anagnorisi tou token.
	// Enw an vgei me BAD, ksexwrizei ta BAD strings, tous BAD numbers kai ta loipa BAD tokens me antistoixous arithmous.
{
	dbg("Scanning.. ");
	State currSt=Q0;
	counter=0;
	while(1)
	{
		switch (currSt)
		{
			case Q0:
				{
					dbg("[Q0] ");
					if (ch=='/'){currSt=O3; break;}
					else if (ch=='*'){currSt=O2; break;}
					else if (ch=='%'){currSt=O1; break;}
					else if (ch=='+'||ch=='-'){currSt=O0; break;}
					else if (ch=='='){currSt=O6; break;}
					else if (ch=='.'){currSt=E1; break;}
					else if (ch=='0'){currSt=I0; break;}
					else if ((ch>='1')&(ch<='9')){currSt=I1; break;}
					else if ((ch>='a'&&ch<='z')||(ch>=0x41&&ch<=0x5A)||(ch=='_')){currSt=V0; break;}
					else if (ch=='\''){currSt=E5; break;}
					else if (ch=='\"'){currSt=E4; break;}
					else if (ch=='#'){currSt=C0; break;}
					else {currSt=BAD; break;}
				}
			case O0:
				{
					dbg("[O0] ");
					if (ch=='0'){currSt=I0; break;}
					else if ((ch>='1')&&(ch<='9')){currSt=I1; break;}
					else if (ch=='.'){currSt=E1; break;}
					else if (ch=='='){currSt=O6; break;}
					else {currSt=GOOD; token=1; break;}
				}
			case O1:
				{
					dbg("[O1] ");
					if (ch=='='){currSt=O6; break;}
					else {currSt=GOOD; token=1; break;}
				}
			case O2:
				{
					dbg("[O2] ");
					if (ch=='='){currSt=O6; break;}
					else if (ch=='*'){currSt=O4; break;}
					else {currSt=GOOD; token=1; break;}
				}
			case O3:
				{
					dbg("[O3] ");
					if (ch=='='){currSt=O6; break;}
					else if (ch=='/'){currSt=O5; break;}
					else {currSt=GOOD; token=1; break;}
				}
			case O4:
				{
					dbg("[O4] ");
					if (ch=='='){currSt=O6; break;}
					else {currSt=GOOD; token=1; break;}
				}
			case O5:
				{
					dbg("[O5] ");
					if (ch=='='){currSt=O6; break;}
					else {currSt=GOOD; token=1; break;}
				}
			case O6:
				{
					dbg("[O6] ");
					currSt=GOOD; token=1; break;
				}
			case I0:
				{
					dbg("[I0] ");
					if ((ch>='0')&&(ch<='9')){currSt=E0; break;}
					else if (ch=='.'){currSt=F0; break;}
					else {currSt=GOOD; token=2; break;}
				}
			case I1:
				{
					dbg("[I1] ");
					if ((ch>='0')&&(ch<='9')){currSt=I1; break;}
					else if (ch=='.'){currSt=F0; break;}
					else {currSt=GOOD; token=2; break;}
				}
			case F0:
				{
					dbg("[F0] ");
					if ((ch=='e')||(ch=='E')){currSt=E2; break;}
					else if ((ch>='0')&&(ch<='9')){currSt=F1; break;}
					else {currSt=GOOD; token=3; break;}
				}
			case F1:
				{
					dbg("[F1] ");
					if ((ch>='0')&&(ch<='9')){currSt=F1; break;}
					else if ((ch=='e')||(ch=='E')){currSt=E2; break;}
					else {currSt=GOOD; token=3; break;}
				}
			case F2:
				{
					dbg("[F2] ");
					if ((ch>='0')&&(ch<='9')){currSt=F2; break;}
					else {currSt=GOOD; token=3; break;}
				}
			case V0:
				{
					dbg("[V0] ");
					if ((ch>='a'&&ch<='z')||(ch>='A'&&ch<='Z')||(ch>='0'&&ch<='9')||(ch=='_')){currSt=V0;break;}
					else {currSt=GOOD; token=4; break;}
				}
			case S0:
				{
					dbg("[S0] ");
					currSt=GOOD; token=5; break;
				}
			case S1:
				{
					dbg("[S1] ");
					currSt=GOOD; token=5; break;
				}
			case S2:
				{
					dbg("[S2] ");
					if(ch=='\"'){currSt=E7; break;}
					else {currSt=GOOD; token=5; break;}
				}
			case C0:
				{
					dbg("[C0] ");
					if (ch>=0x20&&ch<=0x7E){currSt=C0; break;}
					else {currSt=GOOD; token=6; break;}
				}
			case C1:
				{
					dbg("[C1] ");
					if ((ch>=0x23&&ch<=0x7E)||(ch=='!')){currSt=E7; break;}
					else if (ch=='\"'){currSt=C1; break;}
					else {currSt=GOOD; token=6; break;}
				}
			case E0:
				{
					dbg("[E0] ");
					if ((ch>='0')&&(ch<='9')){currSt=E0; break;}
					else if (ch=='.'){currSt=F0; break;}
					else {currSt=BAD; token=11; break;}
				}
			case E1:
				{
					dbg("[E1] ");
					if ((ch>='0')&&(ch<='9')){currSt=F1; break;}
					else {currSt=BAD; token=11; break;}
				}
			case E2:
				{
					dbg("[E2] ");
					if ((ch>='0')&&(ch<='9')){currSt=F2; break;}
					else if ((ch=='+')||(ch=='-')){currSt=E3; break;}
					else {currSt=BAD; token=11; break;}
				}
			case E3:
				{
					dbg("[E3] ");
					if ((ch>='0')&&(ch<='9')){currSt=F2; break;}
					else {currSt=BAD; token=11; break;}
				}
			case E4:
				{
					dbg("[E4] ");
					if ((ch==0x20)||(ch==0x21)||(ch>=0x23&&ch<=0x5B)||(ch>=0x5D&&ch<=0x7E)){delimflag=0;currSt=E6;break;}
					else if (ch=='\\'){delimflag=1; currSt=E6; break;}
					else if (ch=='\"'){if(delimflag==1){delimflag=0;currSt=E6;break;}else{currSt=S2;break;}}
					else {currSt=BAD; token=12; break;}
				}
			case E5:
				{
					dbg("[E5] ");
					if ((ch>=0x20&&ch<=0x26)||(ch>=0x28&&ch<=0x5B)||(ch>=0x5D&&ch<=0x7E)){delimflag=0;currSt=E5;break;}
					else if (ch=='\\'){delimflag=1; currSt=E5; break;}
					else if (ch=='\''){if(delimflag==1){delimflag=0;currSt=E5;break;}else{currSt=S0;break;}}
					else {currSt=BAD; token=12; break;}
				}
			case E6:
				{
					dbg("[E6] ");
					if ((ch==0x20)||(ch==0x21)||(ch>=0x23&&ch<=0x5B)||(ch>=0x5D&&ch<=0x7E)){delimflag=0;currSt=E6;break;}
					else if (ch=='\\'){delimflag=1; currSt=E6; break;}
					else if (ch=='\"'){if(delimflag==1){delimflag=0;currSt=E6;break;}else{currSt=S1;break;}}
					else {currSt=BAD; token=12; break;}
				}
			case E7:
				{
					dbg("[E7] ");
					if ((ch>=0x23&&ch<=0x7E)||(ch==' ')||(ch=='!')||(ch=='\n')||(ch=='\t')){if(ch=='\n'){lcounter++;}currSt=E7; break;} // An vrei newline ayksanei ton metriti grammwn kata 1
					else if (ch=='\"'){currSt=E8; break;}
					else {currSt=BAD; token=12; break;}
				}
			case E8:
				{
					dbg("[E8] ");
					if ((ch>=0x23&&ch<=0x7E)||(ch==' ')||(ch=='!')||(ch=='\n')||(ch=='\t')){if(ch=='\n'){lcounter++;}currSt=E7; break;} // An vrei newline ayksanei ton metriti grammwn kata 1
					else if (ch=='\"'){currSt=E9; break;}
					else {currSt=BAD; token=12; break;}
				}
			case E9:
				{
					dbg("[E9] ");
					if ((ch>=0x23&&ch<=0x7E)||(ch==' ')||(ch=='!')||(ch=='\n')||(ch=='\t')){if(ch=='\n'){lcounter++;}currSt=E7; break;} // An vrei newline ayksanei ton metriti grammwn kata 1
					else if (ch=='\"'){currSt=C1; break;}
					else {currSt=BAD; token=12; break;}
				}
			case GOOD:
				// H periprosi GOOD tha ektyposei ton typo tou token analoga me ton arithmo pou exei h metavliti token.
				// Orizoume 1 gia OPERATOR, 2 gia INTEGER, 3 gia FLOAT klp
				{
					dbg(" ---> ");
					goodtokens++;
					currSt=FOUND;
					tokentmp[counter]='\0';
					if(token==1)
					{
						printf("\t" CYN "<OPERATOR>" RESET " (%d chars) (line:%d)\n",counter,lcounter);
						fprintf(fo,"OPERATOR\t%s\n",tokentmp);
					}
					else if(token==2)
					{
						printf("\t" BLU "<INTEGER>" RESET " (%d chars) (line:%d)\n",counter,lcounter);
						fprintf(fo,"INTEGER\t\t%s\n",tokentmp);						
					}
					else if(token==3)
					{
						printf("\t" BLU "<FLOAT>" RESET " (%d chars) (line:%d)\n",counter,lcounter);
						fprintf(fo,"FLOAT\t\t%s\n",tokentmp);						
					}
					else if (token==4)
					{
						if(chkvar(tokentmp))
						{
							printf("\t<KEPT>(%d chars) (line:%d)\n",counter,lcounter);
							fprintf(fo,"KEPT\t\t%s\n",tokentmp);
						}else{	
							printf("\t" MAG "<VARIABLE>" RESET " (%d chars) (line:%d)\n",counter,lcounter);
							fprintf(fo,"VARIABLE\t%s\n",tokentmp);
						}
						
					}
					else if (token==5)
					{
						printf("\t" GRN "<STRING>" RESET " (%d chars) (line:%d)\n",counter-2,lcounter);
						fprintf(fo,"STRING\t\t%s\n",tokentmp);
						
					}
					else if (token==6)
					{
						printf("\t" YEL "<COMMENT>" RESET " (%d chars) (line:%d)\n",counter,lcounter);	
					}
					break;
				}
			case BAD:
				// Antistoixa h periptosi BAD ektyponei ton typo tou lathous ksexorizontas 2 katastaseis (mia gia arithmous kai mia gia strings)
				// enw an den epiptei to lathos se kapoia apo tis dyo ektiponei apla Bad Token
				// Ousiastika h periptosi BAD se synartisi me to if ths main pou vriskei tous agnostous xaraktires
				// leitourgei san th routina Syntax Error pou zhteitai sthn ergasia
				{
					dbg(" ---> ");
					badtokens++;
					currSt=FOUND;
					if(token==11)
						printf("\t" RED "[Fatal Error] Bad Number" RESET " (%d chars) (line:%d)\n",counter,lcounter);
					else if(token==12)
						printf("\t" RED "[Fatal Error] Bad String" RESET " (%d chars) (line:%d)\n",counter,lcounter);
					else
						printf("\t" RED "[Fatal Error] Bad Token" RESET " (%d chars) (line:%d)\n",counter,lcounter);
					break;
				}
			case FOUND:
				{
					break;
				}
		}
		if (currSt==FOUND){break;}
		else if (currSt!=GOOD&&currSt!=BAD)
		// Stin periptosi pou den exei mpei se katastasi GOOD h' BAD 
		// h synartisi apothikevei ton xaraktira ston prosorino pinaka token
		// diavazei ton epomeno xarakthra
		// kai ayksanei ton metriti xaraktirwn kata 1
		{
			printf("%c",ch);
			tokentmp[counter]=ch;
			ch=fgetc(fp);
			counter++;
		}
	}
}
