%{
#include <iostream>
#include <string>
#include <algorithm>
#include <sstream>
#include <map>
#include <vector>

//definido aqui para que os outros arquivos tenham acesso
#define prefixo_variavel_usuario "VARUSER_"

#include "MapaTipos.h"
#include "MensagensDeErro.h"
#include "ControleDeVariaveis.h"
#include "ControleDeFuncoes.h"
#include "Atributos.h"
#include "EntradaESaida.h"
#include "TratamentoString.h"
#include "ControleDeFluxo.h"
#include "TratamentoArray.h"
#include "TratamentoOperadoresCompostos.h"

#define MSG_ERRO_OPERADOR_LOGICO_COM_OPERANDOS_NAO_BOOLEAN "Os operandos de expressões lógicas precisam ser do tipo boolean"
#define MSG_ERRO_OPERADOR_LOGICO_COM_OPERANDOS_TIPOS_DIFERENTES "Os operandos de expressões relacionais precisam ser do mesmo tipo"
//#define prefixo_variavel_sistema "temp"

#define YYDEBUG 0

using namespace std;

using namespace MapaTipos;
using namespace ControleDeVariaveis;
using namespace MensagensDeErro;
using namespace Atributos;
using namespace EntradaESaida;
using namespace TratamentoString;
using namespace ControleDeFluxo;
using namespace TratamentoArray;
using namespace TratamentoOperadoresCompostos;
using namespace ControleDeFuncoes;

int yylex(void);
void yyerror(string);

bool verificarPossibilidadeDeConversaoExplicita(string, string);
bool ehTipoInputavel(string);
bool ehTipoNaoAtribuivel(string, string);
string verificarTipoResultanteDeCoercao(string, string, string);
ATRIBUTOS tratarExpressaoAritmetica(string, ATRIBUTOS, ATRIBUTOS);
ATRIBUTOS tratarExpressaoAritmeticaComposta(string, ATRIBUTOS, ATRIBUTOS);
ATRIBUTOS tratarExpressaoLogicaBinaria(string, ATRIBUTOS, ATRIBUTOS);
ATRIBUTOS tratarExpressaoLogicaUnaria(string, ATRIBUTOS);
ATRIBUTOS tratarExpressaoLogicaComposta(string, ATRIBUTOS, ATRIBUTOS);
ATRIBUTOS tratarExpressaoRelacional(string, ATRIBUTOS, ATRIBUTOS);
ATRIBUTOS verificarPossibilidadeDeAplicarFuncaoEmExpressao(ATRIBUTOS);
ATRIBUTOS tratarFuncaoEmExpressaoOuAtribuicao(ATRIBUTOS);
//string gerarNovaVariavel();

ATRIBUTOS tratarDeclaracaoSemAtribuicao(ATRIBUTOS, string tipo = "");
ATRIBUTOS tratarDeclaracaoComAtribuicao(ATRIBUTOS, ATRIBUTOS);
ATRIBUTOS tratarAtribuicaoVariavel(ATRIBUTOS, ATRIBUTOS, bool ehDinamica = false);

int conta;

%}

%token TK_NUM
%token TK_BOOL
%token TK_CHAR
%token TK_STRING

%token TK_OP_ARIT_UNA
%token TK_OP_ARIT_PRIO1
%token TK_OP_ARIT_PRIO2
%token TK_OP_ARIT_PRIO3
%token TK_OP_ARIT_COMP_PRIO1
%token TK_OP_ARIT_COMP_PRIO2
%token TK_OP_LOG_BIN_PRIO1
%token TK_OP_LOG_BIN_PRIO2
%token TK_OP_LOG_COMP_PRIO1
%token TK_OP_LOG_COMP_PRIO2
%token TK_OP_LOG_UNA
%token TK_OP_REL_PRIO1
%token TK_OP_REL_PRIO2

//******* I

%token TK_IF
%token TK_ELSE
%token TK_WHILE
%token TK_DO
%token TK_FOR
%token TK_SWITCH
%token TK_CASE
%token TK_DEFAULT
%token TK_BREAK
%token TK_CONTINUE
%token TK_LEN

%token TK_TIPO_INT TK_TIPO_FLOAT TK_TIPO_CHAR TK_TIPO_BOOL TK_TIPO_STRING TK_TIPO_ARRAY TK_PALAVRA_PRINT TK_PALAVRA_SCAN TK_PALAVRA_RETURN
//%token TK_FIM TK_ERROR //estes tokens só tinham uma referência nesse sintatica se quebrar descomentar
%token TK_CONVERSAO_EXPLICITA
//*********** F

%token TK_PALAVRA_VAR TK_ID TK_PALAVRA_FUNC
%token TK_BACKSCOPE TK_PALAVRA_GLOBAL

%start S

%nonassoc IFX
%nonassoc TK_ELSE //Eliminar a ambiguidade inerente do if-else. O yacc por naturalidade já o faz, mas isso evita o reconhecimento do mesmo do conflito de shift/reduce.

%nonassoc TK_OP_ARIT_UNA // ++, --
%nonassoc TK_OP_ARIT_COMP_PRIO1 // +=, -= vide slides LP
%nonassoc TK_OP_ARIT_COMP_PRIO2 //*=, /=
%nonassoc TK_OP_LOG_COMP_PRIO1 //or=
%nonassoc TK_OP_LOG_COMP_PRIO2 //and=
%left TK_OP_LOG_BIN_PRIO1 // or
%left TK_OP_LOG_BIN_PRIO2 // and
%nonassoc TK_OP_REL_PRIO1 // ==, !=
%nonassoc TK_OP_REL_PRIO2 // <, <=, >, >=
%left TK_OP_ARIT_PRIO1 // +, -
%left TK_OP_ARIT_PRIO2 // *, /
%right TK_OP_LOG_UNA // not
%left TK_OP_ARIT_PRIO3 //**

%%


S	 		: COMANDOS
			{

				string fim = "\tgoto FIMCODINTER;\n";
//				cout << "/*Compilador TriadNewScript*/\n" << "#include <stdio.h>\n#include <stdlib.h>\n#include <iostream>\n#include <string.h>\n#include <sstream>\n\n#define TRUE 1\n#define FALSE 0\n\n#define TAMANHO_INICIAL_STRING 10\n#define FATOR_MULTIPLICADOR_STRING 2\n#define FATOR_CARGA_STRING 1\n\n" << substituirTodasAsDeclaracoesProvisorias($1.traducaoDeclaracaoDeVariaveis) << "\nint main(void)\n{\n" << $1.traducao << endl << $6.traducao << "FIMCODINTER:\treturn 0;\n}" << endl;
				cout << "/*Compilador TriadNewScript*/\n" << "#include <stdio.h>\n#include <stdlib.h>\n#include <iostream>\n#include <string.h>\n#include <sstream>\n\n#define TRUE 1\n#define FALSE 0\n\n" << constroiDefinesParaStringDinamica() << substituirTodasAsDeclaracoesProvisorias($1.traducaoDeclaracaoDeVariaveis) << "\n\n" << definicoesDeFuncoes() << "\nint main(void)\n{\n" << $1.traducao << fim << retornarTraducaoFrees() <<"\treturn 0;\n}" << endl;
			}
			;

UP_S		:
			{
				aumentarEscopo();
				if(funcaoEmConstrucao() != "")
					registrarParametrosDaFuncao();
			}
			;

BLOCO		: UP_S '{' COMANDOS '}'
			{
				$$ = $3;
				diminuirEscopo();
				$$.tamanho = $3.tamanho;
			}
			;

COMANDOS	: COMANDO COMANDOS
			{
				$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis + $2.traducaoDeclaracaoDeVariaveis;
				if($1.traducao != "" && $1.estruturaDoConteudo != constante_estrutura_bloco){
					$$.traducao = $1.traducao + "\n";// + constroiPrint($1.tipo, $1.label);
				}
				$$.traducao = $$.traducao + $2.traducao;
			}
			|
			;

COMANDO 	: E ';'
			|
			BLOCO
			|
			INICIO_DECLARACAO ';'
			|
			PRINT ';'
			|
			SCAN ';'
			|
			E_FLUXO_CONTROLE
			|
			E_BREAK_CONTINUE ';'
			|
			RETURN ';'
			;

E			: E TK_OP_ARIT_PRIO1 E
			{
				$$ = tratarExpressaoAritmetica($2.label, $1, $3);
				$$.estruturaDoConteudo = constante_estrutura_expressao;
			}
			|
			E TK_OP_ARIT_PRIO2 E
			{
				$$ = tratarExpressaoAritmetica($2.label, $1, $3);
				$$.estruturaDoConteudo = constante_estrutura_expressao;
			}
			|
			E TK_OP_ARIT_PRIO3 E
			{
				$$ = tratarExpressaoAritmetica($2.label, $1, $3);
				$$.estruturaDoConteudo = constante_estrutura_expressao;
			}
			|
			E TK_OP_LOG_BIN_PRIO1 E
			{
				$$ = tratarExpressaoLogicaBinaria($2.label, $1, $3);
				$$.estruturaDoConteudo = constante_estrutura_expressao;
			}
			|
			E TK_OP_LOG_BIN_PRIO2 E
			{
				$$ = tratarExpressaoLogicaBinaria($2.label, $1, $3);
				$$.estruturaDoConteudo = constante_estrutura_expressao;
			}
			|
			TK_OP_LOG_UNA E
			{
				$$ = tratarExpressaoLogicaUnaria($1.label, $2);
				$$.estruturaDoConteudo = constante_estrutura_expressao;
			}
			|
			E TK_OP_REL_PRIO1 E
			{
				$$ = tratarExpressaoRelacional($2.label,$1,$3);
				$$.estruturaDoConteudo = constante_estrutura_expressao;
			}
			|
			E TK_OP_REL_PRIO2 E
			{
				$$ = tratarExpressaoRelacional($2.label,$1,$3);
				$$.estruturaDoConteudo = constante_estrutura_expressao;
			}
			|
			E TK_OP_ARIT_COMP_PRIO1 E
			{
				$$ = tratarExpressaoAritmeticaComposta($2.label, $1, $3);
				$$.estruturaDoConteudo = constante_estrutura_expressao;

			}
			|
			E TK_OP_ARIT_COMP_PRIO2 E
			{
				$$ = tratarExpressaoAritmeticaComposta($2.label, $1, $3);
				$$.estruturaDoConteudo = constante_estrutura_expressao;

			}
			|
			E TK_OP_LOG_COMP_PRIO1 E
			{
				$$ = tratarExpressaoLogicaComposta($2.label, $1, $3);
				$$.estruturaDoConteudo = constante_estrutura_expressao;

			}
			|
			E TK_OP_LOG_COMP_PRIO2 E
			{
				$$ = tratarExpressaoLogicaComposta($2.label, $1, $3);
				$$.estruturaDoConteudo = constante_estrutura_expressao;

			}
/*
	//tratar este caso em especifico depois ... teste : var a = 1; (-a); gera sintax error
			|
			'(' '-' E ')'
			{

			}
*/
			|
			//por enquanto ambos fazem a msm coisa, mas a ideia seria trocar a ordem das operaçõesç
			TK_OP_ARIT_UNA E
			{
				if($2.estruturaDoConteudo == constante_estrutura_variavel)
				{
					$$ = $2;
					$$.traducao = $2.traducao + "\t" + $2.label + " = " + $2.label + " " + $1.label[0] + " 1;\n";
				}
				else
				{
					string params[2] = {
						$1.label,
						"o operando não é uma variável"
					};
					yyerror(montarMensagemDeErro(MSG_ERRO_OPERADOR_UNARIO_INVALIDO_PARA_OPERANDO, params, 2));
				}
			}
			|
			E TK_OP_ARIT_UNA
			{
				if($1.estruturaDoConteudo == constante_estrutura_variavel)
				{
					$$ = $1;
					$$.traducao = "\t" + $1.label + " = " + $1.label + " " + $2.label[0] + " 1;\n" + $1.traducao;
				}
				else
				{
					string params[2] = {
						$2.label,
						"o operando não é uma variável"
					};
					yyerror(montarMensagemDeErro(MSG_ERRO_OPERADOR_UNARIO_INVALIDO_PARA_OPERANDO, params, 2));
				}
			}
			|
			VALOR
			{
				$$ = $1;
				//cout << $1.labelTamanhoDinamicoString << " << EM E: VALOR\n";
				if($1.estruturaDoConteudo == constante_estrutura_variavel)
					$$.label = $$.escopoDeAcesso > 0 ? recuperarNomeTraducao($$.label, $$.escopoDeAcesso) : recuperarNomeTraducao($$.label);
			}
			|
			TK_CONVERSAO_EXPLICITA VALOR
			{
				if($2.tipo == constante_tipo_funcao){
					$2 = tratarFuncaoEmExpressaoOuAtribuicao($2);
				}

				$$.traducaoDeclaracaoDeVariaveis = $2.traducaoDeclaracaoDeVariaveis;
				$$.traducao = $2.traducao;
				if(verificarPossibilidadeDeConversaoExplicita($2.tipo, $1.tipo)){
					$$.label = gerarNovaVariavel();
					$$.tipo = $1.tipo;
					$$.tamanho = $1.tamanho;
					$$.traducaoDeclaracaoDeVariaveis = $$.traducaoDeclaracaoDeVariaveis + $$.tipo + " " + $$.label + ";\n";

					$$.traducao = $$.traducao + "\t" + $$.label + " = " + $1.label + recuperarNomeTraducao($2.label) + ";\n";
				}else{
					string params[2] = {$2.tipo, $1.tipo};
					yyerror(montarMensagemDeErro(MSG_ERRO_CONVERSAO_EXPLICITA_INDEVIDA, params, 2));
				}
			}
		/*	| comentado em sprint3-merge7
			ARRAY*/
			;

VALOR		: TK_NUM
			{
				$$.label = gerarNovaVariavel();
				$$.traducaoDeclaracaoDeVariaveis = $1.tipo + " " + $$.label + ";\n";
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
				$$.tipo = $1.tipo;
				$$.estruturaDoConteudo = constante_estrutura_tipoPrimitivo;

				if($$.tipo == constante_tipo_inteiro)
				{
					$$.valorNum = stoi($1.label);
				}
			}
			|
			TK_BOOL
			{
				string nomeUpperCase = $1.label;
				transform(nomeUpperCase.begin(), nomeUpperCase.end(), nomeUpperCase.begin(), ::toupper);
				$$.label = nomeUpperCase;
				$$.estruturaDoConteudo = constante_estrutura_tipoPrimitivo;
				//incluirNoMapa($$.label,0, $1.tipo);
				$$.tipo = $1.tipo;
			}
			|
			TK_CHAR
			{
				$$.label = gerarNovaVariavel();
				$$.traducaoDeclaracaoDeVariaveis = $1.tipo + " " + $$.label + ";\n";
				$$.traducao = "\t" + $$.label + " = " + $1.label + ";\n";
				$$.tipo = $1.tipo;
				$$.estruturaDoConteudo = constante_estrutura_tipoPrimitivo;
			}
			|
			STRING
			{
				$$ = $1;
				//cout << "//Entrou em VALOR: STRING\n" << "label1: " << $1.label << "\nlabel$: " << $$.label << endl;
				$$.estruturaDoConteudo = constante_estrutura_tipoPrimitivo;

			}
			|
			ARRAY
			{
				$$ = $1;
				$$.tipo = constante_tipo_array;
				$$.estruturaDoConteudo = $1.estruturaDoConteudo;
			}
			|
			ID
			{
				//cout << "//Entrou em VALOR: ID" << "\n";
				//se for variavel aqui sempre vai existir, pq vai ter que ter passado pela verificação da regra ID: TK_ID
				//e por passar nessa regra terá o tipo já buscado
				if($1.tipo == ""){
					string params[1] = {$1.label};
					//mensagem variavel precisa ter recebido um valor para ter seu tipo definido e atribuido o valor
					yyerror(montarMensagemDeErro(MSG_ERRO_VARIAVEL_UTILIZADA_PRECISA_TER_RECEBIDO_UM_VALOR, params, 1));
				}

				DADOS_VARIAVEL metadata = recuperarDadosVariavel($1.label);
			//	$1.labelTamanhoDinamicoString = metadata.labelTamanhoDinamicoString; //coloquei aqui pq em ID: TK isso volta vazio

				$$ = $1;
				//IMPORTANTE: comentando essas duas linhas pq o william falou que poderia dar problemas na parte dele.
				/*$1.ehDinamica = metadata.ehDinamica;
				$1.tamanho = metadata.tamanho;*/

				//$1.tipo = metadata.tipo; //pode ser que precise
			}
			|
			'(' E ')'
			{
				$$ = $2;
			}
			|
			CHAMADA_FUNCAO
			|
			DECLARACAO_FUNCAO
			|
			VALOR '.' TK_LEN '(' ')'
			{
			//	DADOS_VARIAVEL metadata = recuperarDadosVariavel($.label, $1.escopoDeAcesso);
				$$.label = gerarNovaVariavel();
				$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis + constante_tipo_inteiro + ' ' + $$.label + ";\n";

				if($1.ehDinamica)
				{
					if($1.escopoDeAcesso >= 0)
						$1.labelTamanhoDinamicoString = recuperarLabelTamanhoDinamicoString($1.label, $1.escopoDeAcesso);

					else
						$1.labelTamanhoDinamicoString = recuperarLabelTamanhoDinamicoString($1.label);


					$$.traducao = $1.traducao + '\t' + $$.label + " = " + $1.labelTamanhoDinamicoString + ";\n";
				}
				else
					$$.traducao = $1.traducao + '\t' + $$.label + " = sizeof(" + recuperarNomeTraducao($1.label) + ");\n";

				$$.tipo = constante_tipo_inteiro;

			}
			;

/*Merge manual - sprint3-merge8 - branch de funções*/
DECLARACAO_FUNCAO:
		TK_PALAVRA_FUNC NOME_DECLARACAO_FUNC PARAMETROS_DECLARACAO DECLARACAO_TIPO_RETORNO_FUNC BLOCO
		{
			adcionarTraducaoAoCorpoDaFuncao($5.traducao);
			adcionarTraducaoDeclaracaoAoCorpoDaFuncao($5.traducaoDeclaracaoDeVariaveis);
			//DEFINITIVAMENTE NÃO TROQUE A ORDEM DAS DUAS LINHAS ACIMA
			if(verificarQtdDeRetornos(recuperarNomeTraducao($2.label)) > 0){
				if(verificarSeFezReturnEmTodosOsSubblocos())
				{
					string p[1] = {$2.label};
					yyerror(montarMensagemDeErro(MSG_ERRO_FUNCAO_DEFINIDA_COM_BLOCO_SEM_RETORNAR,p,1));
				}
			}
			$$.label = $2.label;
			$$.tipo = constante_tipo_funcao;
			$$.estruturaDoConteudo = constante_estrutura_funcao;
			finalizarCriacaoFuncao();
		}
		;
//nome da funcao
NOME_DECLARACAO_FUNC:
		TK_ID
		{
			$$ = tratarDeclaracaoSemAtribuicao($1, constante_tipo_funcao);
			criarFuncao(recuperarNomeTraducao($$.label));
		}
		;
//declaracao de parametros
PARAMETROS_DECLARACAO:
		'(' ARGS_FUNC_DECLARACAO ')'
		{
			$$ = $2;
			//imprimirTodosOsParametros();
		}
		|
		'(' ')'
		{
			$$.label = "";
		}
		;
ARGS_FUNC_DECLARACAO: ARGS_FUNC_DECLARACAO ',' ARG_FUNC_DECLARACAO | ARG_FUNC_DECLARACAO ;
ARG_FUNC_DECLARACAO:
		TK_ID ':' TIPO
		{
			//necessario para poder declarar os parametros dentro do escopo da funcao e não fora
			$1.label = prefixo_variavel_usuario + $1.label;
			adicionarParametro($1.label, $3.tipo);
			$$ = $1;
			$$.tipo = $3.tipo;
		}
		|
		TK_ID ':' TK_TIPO_STRING '(' TK_NUM ')'
		{
			$1.label = prefixo_variavel_usuario + $1.label;
			if($5.tipo != constante_tipo_inteiro){
				string p[1] = {constante_tipo_string};
				yyerror(montarMensagemDeErro(MSG_ERRO_TAMANHO_INFORMADO_DEVE_SER_INTEIRO, p, 1));
			}

			adicionarParametro($1.label, $3.tipo, stoi($5.label), false);

		}
		;

//tipo de retorno da funcao
DECLARACAO_TIPO_RETORNO_FUNC: ':' TIPOS_RETORNO | ;
TIPOS_RETORNO: TIPOS_RETORNO ',' TIPO_RETORNO | TIPO_RETORNO ;
TIPO_RETORNO:
		TIPO
		{
			adicionarTipoDeRetorno($1.tipo, false);
		}
		|
		TK_TIPO_STRING '(' TK_NUM ')'
		{
			if($3.tipo != constante_tipo_inteiro){
				string p[1] = {constante_tipo_string};
				yyerror(montarMensagemDeErro(MSG_ERRO_TAMANHO_INFORMADO_DEVE_SER_INTEIRO, p, 1));
			}

			adicionarTipoDeRetorno($1.tipo, stoi($3.label)+1, false);
		}
		;

//chamada da função
CHAMADA_FUNCAO:
		DECLARACAO_FUNCAO PARAMETROS_CHAMADA
		{
			//ESSE ERRO SÓ OCORRE SE FOR POR ERRO DO PRÓPRIO COMPILADOR
			$$ = $1;
			$$.traducao += $2.traducao;

			if(!existeFuncao(recuperarNomeTraducao($1.label, $1.escopoDeAcesso)))
			{
				string p[1] = {$1.label};
				yyerror(montarMensagemDeErro(MSG_ERRO_NOME_DE_FUNCAO_NAO_IDENTIFICADO, p, 1));
			}
			if($2.label != "")
			{
				string msgErro = "";
				if(!verificacaoDeParametros(recuperarNomeTraducao($1.label, $1.escopoDeAcesso), $2.label, &msgErro))
					yyerror(msgErro);
				$$.traducao += gerarTraducaoChamadaDaFuncao(recuperarNomeTraducao($1.label, $1.escopoDeAcesso), $2.label);
			}else{
				int qtdParams = recuperarQuantidadeDeParametros(recuperarNomeTraducao($1.label,$1.escopoDeAcesso));
				//cout << endl << endl << $1.label << endl << endl;
				if(qtdParams > 0){
					string p[3] = {$1.label, "0", to_string(qtdParams)};
					yyerror(montarMensagemDeErro(MSG_ERRO_QUANTIDADE_DE_PARAMETROS_INCOPATiVEL,p,3));
				}
				$$.traducao += "\t" + recuperarNomeTraducao($1.label,$1.escopoDeAcesso) + "();\n";
			}
				$$.traducaoDeclaracaoDeVariaveis += $2.traducaoDeclaracaoDeVariaveis;
				$$.estruturaDoConteudo = constante_estrutura_chamadaFuncao;
		}
		|
		ID PARAMETROS_CHAMADA
		{
			$$.traducao = $2.traducao;

			if($1.tipo != constante_tipo_funcao)
			{
				string p[1] = {$1.label};
				yyerror(montarMensagemDeErro(MSG_ERRO_ID_NAO_REFERENTE_A_UMA_FUNCAO, p, 1));
			}

			string nomeTraducaoId = recuperarNomeTraducao($1.label, $1.escopoDeAcesso);
			if(!existeFuncao(nomeTraducaoId))
			{
				string p[1] = {$1.label};
				yyerror(montarMensagemDeErro(MSG_ERRO_NOME_DE_FUNCAO_NAO_IDENTIFICADO, p, 1));
			}
			if($2.label != "")
			{
				string msgErro = "";
				if(!verificacaoDeParametros(recuperarNomeTraducao($1.label, $1.escopoDeAcesso), $2.label, &msgErro))
					yyerror(msgErro);

			$$.traducao += gerarTraducaoChamadaDaFuncao(recuperarNomeTraducao($1.label, $1.escopoDeAcesso), $2.label);
			}else{
				int qtdParams = recuperarQuantidadeDeParametros(recuperarNomeTraducao($1.label,$1.escopoDeAcesso));
				//cout << endl << endl << $1.label << endl << endl;
				if(qtdParams > 0){
					string p[3] = {$1.label, "0", to_string(qtdParams)};
					yyerror(montarMensagemDeErro(MSG_ERRO_QUANTIDADE_DE_PARAMETROS_INCOPATiVEL,p,3));
				}
				$$.traducao += recuperarNomeTraducao($1.label, $1.escopoDeAcesso) + "();\n";
			}
			$$.traducaoDeclaracaoDeVariaveis = $2.traducaoDeclaracaoDeVariaveis;
			$$.label = $1.label;
			$$.tipo = constante_tipo_funcao;
			$$.estruturaDoConteudo = constante_estrutura_chamadaFuncao;
		}
		;

//parametros de chamada
PARAMETROS_CHAMADA:
		'(' ARGS_FUNC_CHAMADA ')'
		{
			$$ = $2;
			$$.label.pop_back();//remove o ultimo ";" para não gerar um elemento vazio dentro da verificação
		}
		|
		'(' ')'
		{
			$$.label = "";
		}
		;
ARGS_FUNC_CHAMADA:
		ARGS_FUNC_CHAMADA ',' ARG_FUNC_CHAMADA
		{
			$$.traducao = $1.traducao + $3.traducao;
			$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis + $3.traducaoDeclaracaoDeVariaveis;
			$$.label = $1.label + $3.label;
		}
		|
		ARG_FUNC_CHAMADA
		;
ARG_FUNC_CHAMADA:
		E
		{
			if($1.tipo == constante_tipo_funcao){
				if($1.estruturaDoConteudo == constante_estrutura_funcao)
					yyerror(MSG_ERRO_DECLARACAO_DE_FUNCAO_NAO_EH_OPERAVEL_OU_ATRIBUIVEL);

				$$.traducao = $1.traducao;
				$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis;

				DADOS_VARIAVEL retorno;
				string l = "";
				while(retorno.nome != constante_erro){
					retorno = recuperarDadosRetornoDaFuncaoPorChamada(recuperarNomeTraducao($1.label, $1.escopoDeAcesso));
					if(retorno.tipo == constante_tipo_string && !retorno.ehDinamica)
						l += retorno.nome + ":" + retorno.tipo + "(" + to_string(retorno.tamanho) + ");";
					else
						l += retorno.nome + ":" + retorno.tipo + ";";
				}
				$$.label = l;
			}else{
				$$ = $1;

				if($$.tipo == constante_tipo_string && !$$.ehDinamica)
					$$.label = $1.label + ":" + $1.tipo + "(" + to_string($1.tamanho) + ");";
				else
					$$.label = $1.label + ":" + $1.tipo + ";";
			}

		}
		;
RETURN: TK_PALAVRA_RETURN VALORES_RETORNO
		{
			//não precisa verificar se realmente tem uma função aqui pq já verificou nos valores de retorno
			string nomeFuncao = funcaoEmConstrucao();
			DADOS_VARIAVEL r = recuperarDadosRetornoDaFuncaoPorChamada(recuperarNomeTraducao(nomeFuncao));
			if(r.nome != constante_erro){
				string p[3] = {recuperarNome(recuperarLabelFuncaoDaFuncaoEmConstrucao()),
									to_string($2.tamanho),
									to_string(verificarQtdDeRetornos(nomeFuncao))};
				yyerror(montarMensagemDeErro(MSG_ERRO_VALORES_DE_RETORNO_INCOMPATIVEIS, p, 3));
			}

			$$ = $2;
			$$.traducao += "\treturn;\n";
			$$.estruturaDoConteudo = constante_estrutura_comandoReturn;
			adicionarFezRetornoFuncaoAtual($$.tamanho);
		}
		;
VALORES_RETORNO:
		VALORES_RETORNO ',' VALOR_RETORNO
		{
			$$ = $1;
			$$.traducao += $3.traducao;
			$$.traducaoDeclaracaoDeVariaveis += $3.traducaoDeclaracaoDeVariaveis;
			$$.tamanho += $3.tamanho;

		}
		|
		VALOR_RETORNO
		|
		;
VALOR_RETORNO :
		E
		{
			string nomeFuncao = funcaoEmConstrucao();
			if(nomeFuncao == "")
			{
				yyerror(MSG_ERRO_COMANDO_RETURN_USADO_INDEVIDAMENTE);
			}

			string msgErro = "";
			$$.traducao = $1.traducao;
			$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis;
			$$.tamanho = 0; //vai ser usado para contar a quantidade de parametros

			if($1.tipo == constante_tipo_funcao){
				if($1.estruturaDoConteudo == constante_estrutura_funcao)
					yyerror(MSG_ERRO_DECLARACAO_DE_FUNCAO_NAO_EH_OPERAVEL_OU_ATRIBUIVEL);

				vector<DADOS_VARIAVEL> retornoRetorno;
				DADOS_VARIAVEL r;
//				cout << "ar.nome: " << r.nome;
				while(r.nome != constante_erro){
					r = recuperarDadosRetornoDaFuncaoPorChamada(recuperarNomeTraducao($1.label, $1.escopoDeAcesso));
					retornoRetorno.push_back(r);
				}
				retornoRetorno.pop_back();
				for(vector<DADOS_VARIAVEL>::iterator it=retornoRetorno.begin(); it!=retornoRetorno.end();++it)
				{
					r = recuperarDadosRetornoDaFuncaoPorChamada(recuperarNomeTraducao(nomeFuncao));
//					cout << r.tipo << endl << endl;
					if(r.nome == constante_erro){
						string p[2] = {recuperarNome(recuperarLabelFuncaoDaFuncaoEmConstrucao()),
											to_string(verificarQtdDeRetornos(nomeFuncao))};
						yyerror(montarMensagemDeErro(MSG_ERRO_PARAMETRO_A_MAIS_PASSADOS_NO_RETORNO, p, 2));
					}
					if(r.tipo != it->tipo){
						string p[4] = {recuperarNome(recuperarLabelFuncaoDaFuncaoEmConstrucao()),
											to_string($$.tamanho+1),
											it->tipo,
											r.tipo};
							yyerror(montarMensagemDeErro(MSG_ERRO_TIPO_DIFERENTE_ENTRE_VALOR_E_RETORNO,p,4));
					}

					if(r.tipo != constante_tipo_string){
						$$.traducao += "\t" + r.nome + " = " + it->nome + ";\n";
					}else{
						if(r.tamanho != it->tamanho){
							string p[5] = { constante_tipo_string,
											recuperarNome(recuperarLabelFuncaoDaFuncaoEmConstrucao()),
											to_string($$.tamanho+1),
											to_string(it->tamanho),
											to_string(r.tamanho-1)};
							yyerror(montarMensagemDeErro(MSG_ERRO_TAMANHO_DIFERENTE_ENTRE_VALOR_E_RETORNO, p, 5));
						}

						$$.traducao += montarCopiarString(r.nome, it->nome) + ";\n";
					}
					$$.tamanho++;
				}
				//cout << $$.tamanho << endl;
			}else{
				DADOS_VARIAVEL r = recuperarDadosRetornoDaFuncaoPorChamada(recuperarNomeTraducao(nomeFuncao));
				if(r.nome == constante_erro){
					string p[2] = {recuperarNome(recuperarLabelFuncaoDaFuncaoEmConstrucao()),
											to_string(verificarQtdDeRetornos(nomeFuncao))};
					yyerror(montarMensagemDeErro(MSG_ERRO_PARAMETRO_A_MAIS_PASSADOS_NO_RETORNO, p, 2));
				}
				if(r.tipo != $1.tipo){
					//cout << r.tipo << "  " << $1.tipo<< endl;
					string p[4] = {recuperarNome(recuperarLabelFuncaoDaFuncaoEmConstrucao()),
											to_string($$.tamanho+1),
											$1.tipo,
											r.tipo};
					yyerror(montarMensagemDeErro(MSG_ERRO_TIPO_DIFERENTE_ENTRE_VALOR_E_RETORNO,p,4));
				}

				if($1.tipo == constante_tipo_string){
					if($1.tamanho != r.tamanho){
						string p[5] = { constante_tipo_string,
							recuperarNome(recuperarLabelFuncaoDaFuncaoEmConstrucao()),
							to_string($$.tamanho+1),
							to_string($1.tamanho-1),
							to_string(r.tamanho-1)};
							yyerror(montarMensagemDeErro(MSG_ERRO_TAMANHO_DIFERENTE_ENTRE_VALOR_E_RETORNO, p, 5));
					}
						$$.traducao += montarCopiarString(r.nome, $1.label) + ";\n";
				}
				else
					$$.traducao += "\t" + r.nome + " = " + $1.label + ";\n";

				$$.tamanho++;
			}

		}
		;


/*Fim Merge manul - sprint3-merge8 - branch de funções*/

/*Merge manual - sprint3-merge8 - branch de arrays*/

ACESSO_ARRAY	: ID '['
				{
					acessoArray = true;
					dadosArray = recuperarDadosVariavel($1.label,0); //nomeIdOriginal

					//cout << "Label: " << $1.label << endl << "Nome: " << dadosArray.nome << endl << "Tipo: " << dadosArray.tipo << endl;

					$$ = $1;
					$$.acessoArray = true;
					$$.label = $1.label;
				}
				;


ARRAY	: TIPO '[' DIMENSOES_INDICES ']' //Criação de array
		{
			$$.traducaoDeclaracaoDeVariaveis = $3.traducaoDeclaracaoDeVariaveis;
			$$.traducao = $3.traducao;
			$$.valorNum = $3.valorNum;
			$$.ehDinamica = $3.ehDinamica;
			$$.criacaoArray = true; //Para tratamento de erros.
			definicaoTipoArray($1.tipo,$1.label);
			count_dim = 0;
			$$.estruturaDoConteudo = constante_estrutura_tipoPrimitivo;
		}
		|
		'[' ELEM_CHAVES ']'//Criação de array com elementos definidos --> Restrito a duas dimensoes. //ELEMENTOS
		{
			$$ = $2;
			$$.estruturaDoConteudo = constante_estrutura_criacaoArrayPreDefinido;
			$$.criacaoArray = true;
			definicaoTipoArray($2.tipo,tipoCodigoIntermediario($2.tipo));
			$$.tipoArray = $2.tipo;
			$$.traducaoDeclaracaoDeVariaveis = $2.traducaoDeclaracaoDeVariaveis;
			$$.traducao = $2.traducao;

			string label_dim = gerarNovaVariavel();
			adicionarValoresReaisDim(to_string($2.valorNum),true); //Valor da dimensão.
			adicionarTamanhoDimensoesArray(label_dim); //label que terá o tam do vetor.
		}
		|
		ACESSO_ARRAY DIMENSOES_INDICES ']' //ACESSO_ARRAY DIMENSOES_INDICES ']'
		{
			if($1.tipo != constante_tipo_array)
			{
				//dispara erro...
				yyerror("Id informado sendo do tipo Array que não o é.");
			}

			//Verificando se o número de dimensões condiz com a quantidade lida.(No caso se for menor)
			if(pilhaTamanhoDimensoesArray.size() != dadosArray.pilhaTamanhoDimensoesArray.size())
			{
				//dispara erro...
				//cout << pilhaTamanhoDimensoesArray.size() << endl << dadosArray.pilhaTamanhoDimensoesArray.size() << endl << endl;
				yyerror("Dimensões não compatíveis com o array acessado.");
			}
			else
			{
				pair<string,string> tradRetorno;

				$$.ehDinamica = $2.ehDinamica;
				$$.label = $2.label; //Para tratar o caso da pilha ter tamanho 1.

				tradRetorno = traducaoCalculoIndiceArray(pilhaTamanhoDimensoesArray,dadosArray.pilhaTamanhoDimensoesArray,&$$,valoresReaisDim,
																									dadosArray.valoresReaisDim,dadosArray.foiCriadoDinamicamente);

				$$.label = recuperarNomeTraducao($1.label) + "[" + $$.labelIndice + "]";
				$$.labelAux = $1.label;
				$$.traducaoDeclaracaoDeVariaveis = $2.traducaoDeclaracaoDeVariaveis + tradRetorno.first;
				$$.traducao = $2.traducao + tradRetorno.second;
				//$$.tipo = dadosArray.tipoArray;
				tipoArray = dadosArray.tipoArray;
				$$.acessoArray = true;
				$$.tipoArray = dadosArray.tipoArray;
				count_dim = 0; //Terminou a contagem das dimensoes. Aguardando a proxima.
				resetarTamanhoDimensoesArray();

	//			cout << "TRADUCAO VAR: " << endl << $$.traducaoDeclaracaoDeVariaveis << endl << endl;
	//			cout << "TRADUCAO: " << endl << $$.traducao << endl << endl;
			}

		}
		;

ELEM_CHAVES	: ELEM_CHAVES ',' E
						{
								if($1.tipo != $3.tipo || ($3.tipo == constante_tipo_array || $3.tipo == constante_tipo_funcao))
								{
										//dispara erro...
										yyerror("Tipos do vetor pré-determinado são distintos entre si ou são inválidos (array e função).");
								}

								//Por algum motivo o yacc não estava executando o comando $$.valorNum = $1.valorNum + 1 adequadamente.
								$1.valorNum += 1;

								$$.valorNum = $1.valorNum;
								$$ = $1;
								$$.tipo = $1.tipo;
								$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis + $3.traducaoDeclaracaoDeVariaveis;
								$$.traducao = $1.traducao + $3.traducao;
								adicionarTamanhoDimensoesArray($3.label,&labelsDosElementosLidos, true);
						}
						|
						E
						{
							if(($1.tipo == constante_tipo_array || $1.tipo == constante_tipo_funcao))
							{
									//dispara erro...
									yyerror("Tipos do vetor pré-determinado são distintos entre si ou são inválidos (array e função).");
							}

								$$ = $1;
								$$.valorNum = 1;
								//$$.estruturaDoConteudo = $1.estruturaDoConteudo;
								$$.tipo = $1.tipo;
								$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis;
								$$.traducao = $1.traducao;
								adicionarTamanhoDimensoesArray($1.label,&labelsDosElementosLidos, true);
						}
						;

DIMENSOES_INDICES	: DIMENSOES_INDICES ',' E
					{
						if($3.tipo != constante_tipo_inteiro)
						{
							//dispara erro ...
						}
						else if($3.estruturaDoConteudo == constante_estrutura_variavel)
						{
							//Fazer lógica para índice como variável.
							$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis; //TALVEZ SEJA DESNECESSARIO
							$$.traducao = $1.traducao;
							$$.ehDinamica = true;

							if(acessoArray)
							{
								//Verificando se o número de dimensões condiz com a quantidade lida.(No caso de já ter ultrapassado)
								if(count_dim == dadosArray.pilhaTamanhoDimensoesArray.size())
								{
									//dispara erro...
									yyerror("Dimensões não compatíveis com o array acessado.");
								}

								string label_if_index = gerarNovaVariavel();
								string label_cond_if = gerarNovaVariavel();

								$$.traducaoDeclaracaoDeVariaveis = $$.traducaoDeclaracaoDeVariaveis +
																	constante_tipo_inteiro + " " + label_if_index + ";\n" +
																	constante_tipo_inteiro + " " + label_cond_if + ";\n";

								$$.traducao = $$.traducao + "\t" + label_if_index + " = " + $3.label + " < " +
											obterElementoTamanhoDimensoesArray(count_dim,&dadosArray.pilhaTamanhoDimensoesArray,true) +
											";\n\t" + label_cond_if + " = !" + label_if_index + ";\n\t" +
											"if(" + label_cond_if + ")\n\t\t" + "goto " + tag_erro_index + ";\n";

							}

							adicionarTamanhoDimensoesArray(recuperarNomeTraducao($3.label));
							//adicionarTamanhoDimensoesArray(recuperarNomeTraducao($3.label),&valoresReaisDim,true);
							adicionarValoresReaisDim(recuperarNomeTraducao($3.label),false);
							count_dim++;
						}
						else if($3.estruturaDoConteudo == constante_estrutura_expressao)
						{
							$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis + $3.traducaoDeclaracaoDeVariaveis;
							$$.traducao = $1.traducao + $3.traducao;
							$$.ehDinamica = true;

							if(acessoArray)
							{
								//Verificando se o número de dimensões condiz com a quantidade lida.(No caso de já ter ultrapassado)
								if(count_dim == dadosArray.pilhaTamanhoDimensoesArray.size())
								{
									//dispara erro...
									yyerror("Dimensões não compatíveis com o array acessado.");
								}

								string label_if_index = gerarNovaVariavel();
								string label_cond_if = gerarNovaVariavel();

								$$.traducaoDeclaracaoDeVariaveis = $$.traducaoDeclaracaoDeVariaveis +
																	constante_tipo_inteiro + " " + label_if_index + ";\n" +
																	constante_tipo_inteiro + " " + label_cond_if + ";\n";

								$$.traducao = $$.traducao + "\t" + label_if_index + " = " + $3.label + " < " +
											obterElementoTamanhoDimensoesArray(count_dim,&dadosArray.pilhaTamanhoDimensoesArray,true) +
											";\n\t" + label_cond_if + " = !" + label_if_index + ";\n\t" +
											"if(" + label_cond_if + ")\n\t\t" + "goto " + tag_erro_index + ";\n";

							}

							adicionarTamanhoDimensoesArray($3.label);
							//adicionarTamanhoDimensoesArray($3.label,&valoresReaisDim,true); //valoresReaisDim
							adicionarValoresReaisDim($3.label,false);
							count_dim++;
						}
						else //Ele será inteiro de TK_NUM
						{
							$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis + $3.traducaoDeclaracaoDeVariaveis;
							$$.traducao = $1.traducao + $3.traducao;

							if(!acessoArray)
							{
								if($3.valorNum <= 0)
								{
									//dispara erro ...
									yyerror(MSG_ERRO_VALOR_NEGATIVO_ARRAY);
								}
							}
							else
							{
								//Verificando se o número de dimensões condiz com a quantidade lida.(No caso de já ter ultrapassado)
								if(count_dim == dadosArray.pilhaTamanhoDimensoesArray.size())
								{
									//dispara erro...
									yyerror("Dimensões não compatíveis com o array acessado.");
								}

								if($3.valorNum < 0)
								{
									//dispara erro ...
									yyerror(MSG_ERRO_VALOR_NEGATIVO_ARRAY);
								}

								pair<string,bool> num = obterDimInteiraArray(count_dim,&dadosArray.valoresReaisDim,true);

								if(num.second)
								{
										if($3.valorNum >= stoi(num.first))
										{
											//dispara erro...
											//(Aqui queria com a msm mensagem de erro que eu coloquei no código)
											yyerror(MSG_FIM_EXECUCAO_ARRAY);
										}
								}
								else
								{
									string label_if_index = gerarNovaVariavel();
									string label_cond_if = gerarNovaVariavel();

									$$.traducaoDeclaracaoDeVariaveis = $$.traducaoDeclaracaoDeVariaveis +
																		constante_tipo_inteiro + " " + label_if_index + ";\n" +
																		constante_tipo_inteiro + " " + label_cond_if + ";\n";

									$$.traducao = $$.traducao + "\t" + label_if_index + " = " + $3.label + " < " +
												obterElementoTamanhoDimensoesArray(count_dim,&dadosArray.pilhaTamanhoDimensoesArray,true) +
												";\n\t" + label_cond_if + " = !" + label_if_index + ";\n\t" +
												"if(" + label_cond_if + ")\n\t\t" + "goto " + tag_erro_index + ";\n";
								}
							}


							//Fazer lógica para índice como sendo numero inteiro.

							//$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis + $3.traducaoDeclaracaoDeVariaveis;
							//$$.traducao = $1.traducao + $3.traducao;
							$$.valorNum = $$.valorNum * $3.valorNum;
							adicionarTamanhoDimensoesArray($3.label);
							//adicionarTamanhoDimensoesArray(to_string($3.valorNum),&valoresReaisDim,true);
							adicionarValoresReaisDim(to_string($3.valorNum),true);
							count_dim++;
						}
					}
					|
					E
					{
						if($1.tipo != constante_tipo_inteiro)
						{
							//dispara erro ...
						}
						else if($1.estruturaDoConteudo == constante_estrutura_variavel) //É variável, é do tipo inteiro e existe.
						{
							//Fazer lógica para índice como variável.
							$$ = $1; //TALVEZ SEJA DESNECESSARIO
							$$.ehDinamica = true;

							if(acessoArray)
							{
								//Verificando se o número de dimensões condiz com a quantidade lida.(No caso de já ter ultrapassado)
								if(count_dim == dadosArray.pilhaTamanhoDimensoesArray.size())
								{
									//dispara erro...
									yyerror("Dimensões não compatíveis com o array acessado.");
								}

								string label_if_index = gerarNovaVariavel();
								string label_cond_if = gerarNovaVariavel();

								$$.traducaoDeclaracaoDeVariaveis = $$.traducaoDeclaracaoDeVariaveis +
																	constante_tipo_inteiro + " " + label_if_index + ";\n" +
																	constante_tipo_inteiro + " " + label_cond_if + ";\n";

								$$.traducao = $$.traducao + "\t" + label_if_index + " = " + $1.label + " < " +
											obterElementoTamanhoDimensoesArray(count_dim,&dadosArray.pilhaTamanhoDimensoesArray,true) +
											";\n\t" + label_cond_if + " = !" + label_if_index + ";\n\t" +
											"if(" + label_cond_if + ")\n\t\t" + "goto " + tag_erro_index + ";\n";
							}

							adicionarTamanhoDimensoesArray(recuperarNomeTraducao($1.label));
							//adicionarTamanhoDimensoesArray(recuperarNomeTraducao($1.label),&valoresReaisDim,true);
							adicionarValoresReaisDim(recuperarNomeTraducao($1.label),false);
							count_dim++;
						}
						else if($1.estruturaDoConteudo == constante_estrutura_expressao) //Uma expressão com retorno inteiro.
						{
							//$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis;
							//$$.traducao = $1.traducao;
							$$ = $1;
							$$.ehDinamica = true;

							if(acessoArray)
							{

								//Verificando se o número de dimensões condiz com a quantidade lida.(No caso de já ter ultrapassado)
								if(count_dim == dadosArray.pilhaTamanhoDimensoesArray.size())
								{
									//dispara erro...
									yyerror("Dimensões não compatíveis com o array acessado.");
								}

								string label_if_index = gerarNovaVariavel();
								string label_cond_if = gerarNovaVariavel();

								$$.traducaoDeclaracaoDeVariaveis = $$.traducaoDeclaracaoDeVariaveis +
																	constante_tipo_inteiro + " " + label_if_index + ";\n" +
																	constante_tipo_inteiro + " " + label_cond_if + ";\n";

								$$.traducao = $$.traducao + "\t" + label_if_index + " = " + $1.label + " < " +
											obterElementoTamanhoDimensoesArray(count_dim,&dadosArray.pilhaTamanhoDimensoesArray,true) +
											";\n\t" + label_cond_if + " = !" + label_if_index + ";\n\t" +
											"if(" + label_cond_if + ")\n\t\t" + "goto " + tag_erro_index + ";\n";

							}

							adicionarTamanhoDimensoesArray($1.label);
							//adicionarTamanhoDimensoesArray($1.label,&valoresReaisDim,true);
							adicionarValoresReaisDim($1.label,false);
							count_dim++;
						}
						else //Ele será inteiro de TK_NUM
						{
							$$ = $1;

							if(!acessoArray)
							{
								if($1.valorNum <= 0)
								{
									//dispara erro ...
									yyerror(MSG_ERRO_VALOR_NEGATIVO_ARRAY);
								}
							}
							else
							{
								//Verificando se o número de dimensões condiz com a quantidade lida.(No caso de já ter ultrapassado)
								if(count_dim == dadosArray.pilhaTamanhoDimensoesArray.size())
								{
									//dispara erro...
									yyerror("Dimensões não compatíveis com o array acessado.");
								}

								if($1.valorNum < 0)
								{
									//dispara erro ...
									yyerror(MSG_ERRO_VALOR_NEGATIVO_ARRAY);
								}

								pair<string,bool> num = obterDimInteiraArray(count_dim,&dadosArray.valoresReaisDim,true);

								if(num.second)
								{
										if($1.valorNum >= stoi(num.first))
										{
											//dispara erro...
											//(Aqui queria com a msm mensagem de erro que eu coloquei no código)
											yyerror(MSG_FIM_EXECUCAO_ARRAY);
										}
								}
								else
								{
									string label_if_index = gerarNovaVariavel();
									string label_cond_if = gerarNovaVariavel();

									$$.traducaoDeclaracaoDeVariaveis = $$.traducaoDeclaracaoDeVariaveis +
																		constante_tipo_inteiro + " " + label_if_index + ";\n" +
																		constante_tipo_inteiro + " " + label_cond_if + ";\n";

									$$.traducao = $$.traducao + "\t" + label_if_index + " = " + $1.label + " < " +
												obterElementoTamanhoDimensoesArray(count_dim,&dadosArray.pilhaTamanhoDimensoesArray,true) +
												";\n\t" + label_cond_if + " = !" + label_if_index + ";\n\t" +
												"if(" + label_cond_if + ")\n\t\t" + "goto " + tag_erro_index + ";\n";

								}
							}

							//Fazer lógica para índice como sendo numero inteiro.
							//$$ = $1;
							adicionarTamanhoDimensoesArray($1.label);
							//adicionarTamanhoDimensoesArray(to_string($1.valorNum),&valoresReaisDim,true);
							adicionarValoresReaisDim(to_string($1.valorNum),true);
							count_dim++;
						}
					}
					;

/*Fim merge manual - sprint3-merge8 - branch de arrays*/


ID			: TK_ID
			{
			//	cout << "//Entrou em ID: TK_ID\n";
				if(variavelJaDeclarada($1.label))
				{
					DADOS_VARIAVEL metaData = recuperarDadosVariavel($1.label);
					$$.label = metaData.nome;
					$$.tipo = metaData.tipo;
					$$.estruturaDoConteudo = constante_estrutura_variavel;
					$$.tamanho = metaData.tamanho;
					$$.ehDinamica = metaData.ehDinamica;
				//	cout << metaData.labelTamanhoDinamicoString << " << em ID\n"; Isso só imprime vazio
			//		cout << "//Entrou em ID: TK_ID\n" << "metaData.nome: " << metaData.nome << "\nlabel$: " << $$.label << "label1: " << $1.label << endl;
					//$$.nomeIdOriginal = $1.label; //Subir nome original.
				}
				else
				{
					string params[1] = {$1.label};
					yyerror(montarMensagemDeErro(MSG_ERRO_VARIAVEL_NAO_DECLARADA ,params, 1));
				}

			}
			|
			'(' TK_BACKSCOPE TK_NUM ')' TK_ID
			{
				if($3.tipo != constante_tipo_inteiro){
					string params[1] = {$3.tipo};
					yyerror(montarMensagemDeErro(MSG_ERRO_PARAMETRO_BACKSCOPE_DEVE_SER_INTEIRO, params, 1));
				}

				int qtdRetornoEscopo = stoi($3.label);
				if(ehMaiorIgualQueEscopoAtual(qtdRetornoEscopo))
					yyerror(montarMensagemDeErro(MSG_ERRO_PARAMETRO_BACKSCOPE_MAIOR_OU_IGUAL_ESCOPO_ATUAL));

				int escopo = escopoResultante(qtdRetornoEscopo);

				if(variavelJaDeclarada($5.label, true, escopo)){
					DADOS_VARIAVEL metaData = recuperarDadosVariavel($5.label, escopo);
					$$.tipo = metaData.tipo;
					$$.tamanho = metaData.tamanho;
					$$.ehDinamica = metaData.ehDinamica;
					$$.label = metaData.nome;
					if($$.tipo == "")
						$$.estruturaDoConteudo = constante_estrutura_variavelSemTipo;
					else
						$$.estruturaDoConteudo = constante_estrutura_variavel;

					$$.escopoDeAcesso = escopo;


					//$$.nomeIdOriginal = $1.label; //Subir nome original.

				}else{
					string params[1] = {$5.label};
					yyerror(montarMensagemDeErro(MSG_ERRO_VARIAVEL_NAO_DECLARADA_NO_ESCOPO ,params, 1));
				}
			}
			|
			'(' TK_PALAVRA_GLOBAL ')' TK_ID
			{
				if(variavelJaDeclarada($4.label, false, 0)){
					DADOS_VARIAVEL metaData = recuperarDadosVariavel($4.label, 0);
					$$.tipo = metaData.tipo;
					$$.tamanho = metaData.tamanho;
					$$.ehDinamica = metaData.ehDinamica;
					if($$.tipo == "")
						$$.estruturaDoConteudo = constante_estrutura_variavelSemTipo;
					else
						$$.estruturaDoConteudo = constante_estrutura_variavel;

					$$.escopoDeAcesso = 0;

					//$$.nomeIdOriginal = $1.label; //Subir nome original.

				}else{
					string params[1] = {$4.label};
					yyerror(montarMensagemDeErro(MSG_ERRO_VARIAVEL_NAO_DECLARADA_NO_ESCOPO ,params, 1));
				}
			}
			;

STRING	: TK_STRING
			{
			//	cout << "Entrou em TK_STRING\n";
			//	$$.label = gerarNovaVariavel();
			//	cout << "//Entrou em STRING: TK_STRING\n" << "label1: " << $1.label << "\nlabel$: " << $$.label << endl;
				$$.tamanho = atualizarTamanhoString($1.label.length()); //tamanho modificado pelo \0 e pelas aspas
		//		$$.traducaoDeclaracaoDeVariaveis = "char " + $$.label + "[" + to_string($$.tamanho) + "];\n";
				$$.label = $1.label;
			}
			;

/*
ATRIBUICAO_POR_FUNCAO:
	TK_PALAVRA_VAR MULTIPLOS_IDS
	{
	}
	|
	MULTIPLOS_IDS
	{
	}
	;*/

/*
MULTIPLOS_IDS:
		MULTIPLOS_IDS '|' TK_ID '<''=' E
		|
		TK_ID
		|
		TK_PALAVRA_VAR TK_ID
		;
		*/
INICIO_DECLARACAO	: CRIACAO_VARIAVEL ',' MULTI_DECLARACAO
					{
						$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis + $3.traducaoDeclaracaoDeVariaveis;
						$$.traducao = $1.traducao + $3.traducao;
					}
					|
					CRIACAO_VARIAVEL
					|
					ATRIBUICAO_VARIAVEL
					;

MULTI_DECLARACAO	: ATRIBUICAO_VARIAVEL_CRIACAO ',' MULTI_DECLARACAO
					{
						$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis + $3.traducaoDeclaracaoDeVariaveis;
						$$.traducao = $1.traducao + $3.traducao;
				//		cout << "//Entrou em MULTI_DECLARACAO: ATRIBUICAO_VARIAVEL_CRIACAO , MULTI_DECLARACAO\n" << "label1: " << $1.label << "\nlabel$: " << $$.label << "\nlabel3" << $3.label <<endl;
					}
					|
					ATRIBUICAO_VARIAVEL_CRIACAO
					;

CRIACAO_VARIAVEL	: TK_PALAVRA_VAR TK_ID
					{
						$$ = tratarDeclaracaoSemAtribuicao($2);
						//$$.tipo = constante_tipo_criacao_sem_atribuicao;
						$$.estruturaDoConteudo = constante_estrutura_variavelSemTipo;
						$$.label = $2.label;
				//		cout << "//Entrou em CRIACAO_VARIAVEL TK_PALAVRA_VAR TK_ID\n" << "label2: " << $2.label << "\nlabel$: " << $$.label << endl;
					}
					|
					TK_PALAVRA_VAR TK_ID '=' E
					{
						$$ = tratarDeclaracaoComAtribuicao($2,$4);
			//			cout << "--ATRIBUICAO_VARIAVEL----------------\n";
				//		cout << "label2: " << $2.label << " tamaho: " << $2.tamanho << endl;
					//	cout << "label4: " << $4.label << " tamaho: " << $4.tamanho << endl;
						//cout << "label$$: " << $$.label << " tamaho: " << $$.tamanho << endl;
						//cout << "------------------\n";
					}
					;

ATRIBUICAO_VARIAVEL_CRIACAO	:  TK_ID '=' E
					{
						$$ = tratarDeclaracaoComAtribuicao($1,$3);
						//cout << "//++ATRIBUICAO_VARIAVEL----------------\n";
					//	cout << "label1: " << $1.label << " tamaho: " << $1.tamanho << endl;
						//cout << "label3: " << $3.label << " tamaho: " << $3.tamanho << endl;
						//cout << "label$$: " << $$.label << " tamaho: " << $$.tamanho << endl;
						//cout << "//------------------\n";

					}
					|
					TK_ID
					{
						$$ = tratarDeclaracaoSemAtribuicao($1);
					}
					;

ATRIBUICAO_VARIAVEL	:  ID '=' E
					{
				//		cout << "//Entrou em ID '=' VALOR_ATRIBUICAO\n";

						if($1.tipo == constante_tipo_array && !$3.criacaoArray)
						{
							//dispara erro...
							yyerror("Tipo do lado esquerdo é Array, sendo que o lado direito é um livia[x,y]");
						}
						else
						{
							$$ = tratarAtribuicaoVariavel($1,$3,$3.ehDinamica);
						}

					}
					|
					ARRAY '=' E //Caso livia[x1,x2,...,xn] = compilador[x1,x2,...,xm] OU livia[x1,x2,...,xn] = 90;
					{
						//O usuário poderia escrever int[x,y] = int[u,v] ; int[x,y] = 90/livia[x,y]/2.3
						if($1.criacaoArray)
						{
							//dispara erro...
							yyerror("Array de criação do lado esquerdo sendo atribuido incorretamente.");
						}

						if($1.acessoArray && $3.criacaoArray) //O usuário poderia escrever livia[x,y] = int[x,y]
						{
							yyerror("Array de criação do lado esquerdo sendo atribuido incorretamente.");
						}

						//int[x,y] = int[3,4] ; livia[x,y] = int[4,5] ; int[x,y] = 90/livia[x,y]/2.3
						//	F			F			T			F			F		F	T			F

						//livia[x,y] = 90 / a[x,y],livia[u,v] / 2.3
						//		T		F			T			F

						$$ = tratarAtribuicaoVariavel($1,$3);
					}
					|
					ARRAY '=' E //Caso livia[x1,x2,...,xn] = compilador[x1,x2,...,xm] OU livia[x1,x2,...,xn] = 90;
					{

						//O usuário poderia escrever int[x,y] = int[u,v] ; int[x,y] = 90/livia[x,y]/2.3
						if($1.criacaoArray)
						{
							//dispara erro...
							yyerror("Array de criação do lado esquerdo sendo atribuido incorretamente.");
						}

						if($1.acessoArray && $3.criacaoArray) //O usuário poderia escrever livia[x,y] = int[x,y]
						{
							yyerror("Array de criação do lado esquerdo sendo atribuido incorretamente.");
						}

						//int[x,y] = int[3,4] ; livia[x,y] = int[4,5] ; int[x,y] = 90/livia[x,y]/2.3
						//	F			F			T			F			F		F	T			F

						//livia[x,y] = 90 / a[x,y],livia[u,v] / 2.3
						//		T		F			T			F

						$$ = tratarAtribuicaoVariavel($1,$3);
					}
					;

PRINT			: TK_PALAVRA_PRINT '(' ARG_PRINT ')'
			{
				$$.traducaoDeclaracaoDeVariaveis = $$.traducaoDeclaracaoDeVariaveis + $3.traducaoDeclaracaoDeVariaveis;
				$$.traducao = $$.traducao + $3.traducao;

			}
			;


ARG_PRINT: E
			{
				$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis;
				if($1.tipo == constante_tipo_funcao)
					$1 = tratarFuncaoEmExpressaoOuAtribuicao($1);
				$$.traducao = $1.traducao + "\n" + constroiPrint(recuperarNomeTraducao($1.label, $1.escopoDeAcesso));
			}
			;

SCAN			: TK_PALAVRA_SCAN '(' ARGS_SCAN ')'
			{
				//cout << " // Entrei em TK_PALAVRA_SCAN '(' ARGS_SCAN ')'';' \n";
				$$.traducaoDeclaracaoDeVariaveis = $$.traducaoDeclaracaoDeVariaveis + $3.traducaoDeclaracaoDeVariaveis;
				$$.traducao = $$.traducao + $3.traducao;
				$$.labelTamanhoDinamicoString = $3.labelTamanhoDinamicoString;

			}
			;

ARGS_SCAN		: ARG_SCAN ',' ARGS_SCAN
			{
				//cout << $1.traducaoDeclaracaoDeVariaveis << " *******\n";
				$$.traducaoDeclaracaoDeVariaveis = $2.traducaoDeclaracaoDeVariaveis + $1.traducaoDeclaracaoDeVariaveis;
				$$.traducao = $2.traducao + $1.traducao;
				$$.labelTamanhoDinamicoString = $1.labelTamanhoDinamicoString;

			}
			|
			ARG_SCAN
			{
				$$.labelTamanhoDinamicoString = $1.labelTamanhoDinamicoString;


			}

			;

ARG_SCAN		: ID ':' TIPO
			{
	//			cout << "\n//Entrou em ID TIPO\n";
				/*else if(metadata.tipo != $3.tipo)
				{
				//TODO: criar mensagem de erro própria para o input
					string strPrefixoVarUsuario = prefixo_variavel_usuario;
					string params[3] = {$1.label.replace(0, strPrefixoVarUsuario.length(), ""), $1.tipo, $3.tipo};
				yyerror(montarMensagemDeErro(MSG_ERRO_ATRIBUICAO_DE_TIPOS_DIFERENTES, params, 3));
				}*/
				bool ehDinamica = true;
		/*		ATRIBUTOS $$;
				$$ = copiarDadosAtributos($$);
				$$ = concatenarTraducoesAtributos($$,$$);
				imprimirAtributos($$);
				imprimirAtributos($$);*/
				$$ = tratarAtribuicaoVariavel($1, $3, ehDinamica);
				$$.label = gerarNovaVariavel();
				string dolarDolar = $$.label;
				int tamanho = 0;
				$$.traducao = "";
				int escopo = numeroEscopoAtual;
				if($$.escopoDeAcesso >= 0)
					escopo = $$.escopoDeAcesso;

				if(!ehTipoInputavel($1.tipo)){
					string params[1] = {$1.tipo};
					yyerror(montarMensagemDeErro(MSG_ERRO_TIPO_NAO_INPUTAVEL, params, 1));
				}

				if($3.tipo == constante_tipo_string)
				{
					//adicionarDefinicaoDeTipo($1.label, $3.tipo,tamanho,ehDinamica);

					string labelRecuperada = recuperarNomeTraducao($1.label, escopo);
					$$.traducaoDeclaracaoDeVariaveis = $$.traducaoDeclaracaoDeVariaveis + "char * " + $$.label + ";\n";

					$$ =  traducaoStringDinamica($$, labelRecuperada);
					$$.traducao = $$.traducao + montarCopiarString(labelRecuperada, $$.label) + ";\n";

					if($1.escopoDeAcesso >= 0)
						atualizarLabelTamanhoDinamicoNoMapa($1.label, $$.labelTamanhoDinamicoString, $1.escopoDeAcesso);

					else
					atualizarLabelTamanhoDinamicoNoMapa($1.label, $$.labelTamanhoDinamicoString);


				}

				else
				{
					$$.traducaoDeclaracaoDeVariaveis = $$.traducaoDeclaracaoDeVariaveis + tipoCodigoIntermediario($3.label) + " " + $$.label + ";\n";
					$$.traducao =  constroiScan($$.label, $3.tipo);
					if($3.tipo == constante_tipo_booleano)
					{
						$$ = validarEntradaBooleanEmTempoExecucao($$);

					}

					$$.traducao = $$.traducao + "\t" + recuperarNomeTraducao($1.label, escopo) + " = " + $$.label + ";\n";

				}

			}
			;

TIPO: TK_TIPO_INT
	|
	TK_TIPO_FLOAT
	|
	TK_TIPO_CHAR
	|
	TK_TIPO_BOOL
	|
	TK_TIPO_STRING
	;



E_FLUXO_CONTROLE	: COMANDO_IF
				|
				COMANDO_WHILE
				|
				COMANDO_DOWHILE
				|
				COMANDO_FOR
				|
				COMANDO_SWITCH
				;

COMANDO_IF	: TK_IF '(' E ')' COMANDO %prec IFX
			{
				if($3.tipo != constante_tipo_booleano) ;
					//dispara erro ...

				$$.label = gerarNovaVariavel();
				$$.traducaoDeclaracaoDeVariaveis = $3.traducaoDeclaracaoDeVariaveis + $5.traducaoDeclaracaoDeVariaveis +
													constante_tipo_inteiro + " " + $$.label + ";\n";

				string tagFim = gerarNovaTagIf(true);

				$$.traducao = $3.traducao + "\t" + $$.label + " = " + "!" + $3.label + ";\n" +
							"\t" + "if" + "(" + $$.label + ")\n" + "\t\t" + "goto " + tagFim + ";\n" +
							$5.traducao + "\t" + tagFim + ":;\n";
			}
			|
			TK_IF '(' E ')' COMANDO TK_ELSE COMANDO
			{
				if($3.tipo != constante_tipo_booleano) ;
					//dispara erro ...

				//cout << "Traducao String: " << endl << $3.traducao << endl << endl << "Traducao de Var String: " << endl << $3.traducaoDeclaracaoDeVariaveis << endl << endl;
				//cout << "Label String: " << $3.label << endl << endl;

				$$.label = gerarNovaVariavel();
				$$.traducaoDeclaracaoDeVariaveis = $3.traducaoDeclaracaoDeVariaveis + $5.traducaoDeclaracaoDeVariaveis +
													$7.traducaoDeclaracaoDeVariaveis +
													constante_tipo_inteiro + " " + $$.label + ";\n";

				//Criar tag para pular o bloco do else (que ficara logo em seguida no cod. interm.)
				string tagBlocoIf = gerarNovaTagIf(false);
				//Criar tag de fim do if.
				string tagFim = gerarNovaTagIf(true);

				$$.traducao = $3.traducao + "\t" + $$.label + " = " + $3.label + ";\n" +
								"\t" + "if" + "(" + $$.label + ")\n" + "\t\t" + "goto " + tagBlocoIf + ";\n" +
								$7.traducao + "\t" + "goto " + tagFim + ";\n" + "\t" + tagBlocoIf + ":\n" +
								$5.traducao + "\t" + tagFim + ":;\n";
			}
			;

EMPILHAR_TAG_WHILE	:
					{
						string tagInicio = gerarNovaTagWhile(false);
						string tagFim = gerarNovaTagWhile(true);
						adicionarTagInicio(tagInicio);
						adicionarTagFim(tagFim);
					}
					;

COMANDO_WHILE	: EMPILHAR_TAG_WHILE TK_WHILE '(' E ')' COMANDO
				{
					if($4.tipo != constante_tipo_booleano) ;
						//dispara erro ...

					string tagInicio = obterTopoPilhaInicio();
					string tagFim = obterTopoPilhaFim();

					$$.label = gerarNovaVariavel();
					$$.traducaoDeclaracaoDeVariaveis = $4.traducaoDeclaracaoDeVariaveis + $6.traducaoDeclaracaoDeVariaveis +
														constante_tipo_inteiro + " " + $$.label + ";\n";

					$$.traducao = "\t" + tagInicio + ":\n" + $4.traducao + "\t" + $$.label + " = " + "!" + $4.label + ";\n" +
									"\t" + "if" + "(" + $$.label + ")\n" + "\t\t" + "goto " + tagFim + ";\n" +
									$6.traducao + "\t" + "goto " + tagInicio + ";\n" +
									"\t" + tagFim + ":;\n";

					removerTopoTagInicio();
					removerTopoTagFim();
				}
				;

EMPILHAR_TAG_DOWHILE	:
					{
						string tagInicio = gerarNovaTagDoWhile(false);
						string tagFim = gerarNovaTagDoWhile(true);

						adicionarTagInicio(tagInicio);
						adicionarTagFim(tagFim);
					}
					;

COMANDO_DOWHILE	: EMPILHAR_TAG_DOWHILE TK_DO COMANDO TK_WHILE '(' E ')' ';' //PROBLEMAS COM O COMANDO ----> RESOLVIDO
				{
					if($6.tipo != constante_tipo_booleano);
						//dispara erro ...

					string tagInicio = obterTopoPilhaInicio();
					string tagFim = obterTopoPilhaFim();

					$$.label = gerarNovaVariavel();
					$$.traducaoDeclaracaoDeVariaveis = $6.traducaoDeclaracaoDeVariaveis + $3.traducaoDeclaracaoDeVariaveis +
														constante_tipo_inteiro + " " + $$.label + ";\n";

					$$.traducao = "\t" + tagInicio + ":\n" + $3.traducao +
									$6.traducao + "\t" + $$.label + " = " + "!" + $6.label + ";\n" +
									"\t" + "if" + "(" + $$.label + ")\n" + "\t\t" + "goto " + tagFim + ";\n" +
									"\t" + "goto " + tagInicio + ";\n" +
									"\t" + tagFim + ":;\n";

					removerTopoTagInicio();
					removerTopoTagFim();
				}
				;

INIT	: INIT_VAR
		|
		{ //MESMO PROBLEMA DO BLOCO REPETIDO NO FINAL!
			$$.traducaoDeclaracaoDeVariaveis = "";
			$$.traducao = "";
			$$.label = "";
			$$.tipo = "";
		}
		;


INIT_VAR	: INITS ',' INIT_VAR
		{
			$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis + $3.traducaoDeclaracaoDeVariaveis;
			$$.traducao = $1.traducao + $3.traducao;
		}
		|
		INITS
		;

INITS	: CRIACAO_VARIAVEL
		{
			//$1.tipo == constante_tipo_criacao_sem_atribuicao
			if($1.estruturaDoConteudo == constante_estrutura_variavelSemTipo){

				string params[1] = {$1.label};
				yyerror(montarMensagemDeErro(MSG_ERRO_VARIAVEL_SEM_ATRIBUICAO_FOR,params,1));
			}else{
				$$ = $1;
			}
		}
		/*
		TK_PALAVRA_VAR TK_ID '=' VALOR_ATRIBUICAO
		{
			$$ = tratarDeclaracaoComAtribuicao($2,$4);
		}
		*/
		|
		ATRIBUICAO_VARIAVEL
		;

CONDICAO	: E
			{
				if($1.tipo != constante_tipo_booleano);
					//dispara erro ...
				$$ = $1;
			}
			|
			{ //MESMO PROBLEMA DO BLOCO REPETIDO NO FINAL!
				/*
				$$.traducaoDeclaracaoDeVariaveis = "";
				$$.traducao = "";
				$$.label = "";
				$$.tipo = constante_tipo_condicao_vazia_for;
				*/
				yyerror(MSG_ERRO_FOR_SEM_CONDICAO);
			}
			;

//Separação feita para evitar o reconhecimento de sentenças que finalizem com ','.
UPDATE	: UPDATE_VAR
		|
		{ //MESMO PROBLEMA DO BLOCO REPETIDO NO FINAL!
			$$.traducaoDeclaracaoDeVariaveis = "";
			$$.traducao = "";
			$$.label = "";
			$$.tipo = "";
		}
		;

UPDATE_VAR	: UPDATES ',' UPDATE_VAR
			{
				$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis + $3.traducaoDeclaracaoDeVariaveis;
				$$.traducao = $1.traducao + $3.traducao;
			}
			|
			UPDATES
			;


UPDATES	: ATRIBUICAO_VARIAVEL
		|
		E
		{

			if($1.estruturaDoConteudo == constante_estrutura_expressao){
				//dispara erro ...
				if($1.tipo != constante_tipo_booleano){
					if(variavelJaDeclarada($1.label)){
						$$ = $1;
					}
					else{
						//dispara erro ex: 1 + 1
					}
				}else{
					// dispara erro 10 < 3
				}
			}else{
				//dispara erro ex: vairiavel
			}
		}
		/*
		{
			string numNeg = "(-1)";
			if($1.traducao.find(numNeg) == std::string::npos){
				$$ = $1;
			}else{
				yyerror(MSG_ERRO_UPDATE_FOR_SEM_ATRIBUICAO);
			}
		}
		*/
		;


EMPILHAR_TAG_FOR	:
					{
						//string tagInicio = gerarNovaTagFor(false);
						string tagInicio = gerarNovaTagUpdateFor();
						string tagFim = gerarNovaTagFor(true);
						adicionarTagInicio(tagInicio);
						adicionarTagFim(tagFim);
					}
					;

COMANDO_FOR	: EMPILHAR_TAG_FOR TK_FOR '(' INIT ';' CONDICAO ';' UPDATE ')' COMANDO
			{
				string tagInicio = gerarNovaTagFor(false);
				string tagUpdate = obterTopoPilhaInicio();
				string tagFim = obterTopoPilhaFim();

				$$.label = gerarNovaVariavel();
				$$.traducaoDeclaracaoDeVariaveis = $4.traducaoDeclaracaoDeVariaveis + $6.traducaoDeclaracaoDeVariaveis +
													$8.traducaoDeclaracaoDeVariaveis + $10.traducaoDeclaracaoDeVariaveis
													+ constante_tipo_inteiro + " " + $$.label + ";\n";

				//if($6.tipo != constante_tipo_condicao_vazia_for){

					$$.traducao = $4.traducao + "\t" + tagInicio + ":\n" +
									$6.traducao + "\t" + $$.label + " = " + "!" + $6.label + ";\n" +
									"\t" + "if" + "(" + $$.label + ")\n" + "\t\t" + "goto " + tagFim + ";\n" +
									$10.traducao + "\t" + tagUpdate + ":\n" +
									$8.traducao + "\t" + "goto " + tagInicio + ";\n" +
									"\t" + tagFim + ":;\n";
				//}else{
					/*
					$$.traducao = $4.traducao + "\t" + tagInicio + ":\n" +
									$10.traducao + $8.traducao + "\t" + "goto " + tagInicio + ";\n" +
									"\t" + tagFim + ":\n";
					*/
				//}

				removerTopoTagInicio();
				removerTopoTagFim();
			}
			;

EMPILHAR_TAG_SWITCH	:
					{
						pair<string,int> tagFim = gerarNovaTagSwitch(false);
						adicionarTagFim(tagFim.first);
					}
					;

COMANDO_SWITCH	: EMPILHAR_TAG_SWITCH TK_SWITCH '(' E ')' '{' CASES DEFAULT'}'
				{
					if($4.estruturaDoConteudo != constante_estrutura_variavel)
					{
						//dispara erro... precisa ser variavel
					}

					//$3.tipo != constante_tipo_string && $3.tipo != constante_tipo_flutuante
					if($4.tipo == $7.tipo) {
						//(...)
						//pair<string,int> tagFimENumProx = gerarNovaTagSwitch(false);
						//string tagCaseAtual = tag_case_inicio + to_string(tagFimENumProx.second);
						pair<string,int> tagFimENumProx = gerarNovaTagSwitch(true);
						string tagCaseAtual = tag_case_inicio + to_string(tagFimENumProx.second-1);
						pair<string,string> condicaoCase = gerarNovaTagCondicaoCase();


						//string tagFim = gerarNovaTagSwitch(false).first;

						//$$.label = gerarNovaVariavel();

						//Outra parte da árvore já tera a $3.traducaoDeclaracaoDeVariaveis salva. Portanto, teríamos repetição.
						$$.traducaoDeclaracaoDeVariaveis = $7.traducaoDeclaracaoDeVariaveis + $8.traducaoDeclaracaoDeVariaveis;

						if($8.tipo == constante_tipo_default){

							$$.traducao = $4.traducao + $7.traducao + $8.traducao +
										//"\t" + "goto " + tagFim + ";\n"
										//"\t" + tagFimENumProx.first + ":\n";
										"\t" + obterTopoPilhaFim() + ":;\n";

						}else{
							$$.traducao = $4.traducao + $7.traducao + $8.traducao +
										//"\t" + "goto " + tagFim + ";\n"
										"\t" + condicaoCase.first + ":\n" +
										"\t" + tagCaseAtual + ":\n" +
										//"\t" + tagFimENumProx.first + ":\n";
										"\t" + obterTopoPilhaFim() + ":;\n";
						}

						$$.traducao = substituirVariaveisCase($$.traducao, recuperarNomeTraducao($4.label));
						removerTopoTagFim();

					}
					else{
						yyerror(MSG_ERRO_TIPO_CASE_DISTINTO);
					}
				}
				;

DEFAULT	: TK_DEFAULT ':' COMANDO
		{
			pair<string,int> tagFimENumProx = gerarNovaTagSwitch(true);
			string tagCaseAtual = tag_case_inicio + to_string(tagFimENumProx.second-1);
			pair<string,string> condicaoCase = gerarNovaTagCondicaoCase();

			$$.traducaoDeclaracaoDeVariaveis = $3.traducaoDeclaracaoDeVariaveis;
			$$.traducao = "\t" + condicaoCase.first + ":\n" +
							"\t" + tagCaseAtual + ":\n" + $3.traducao;
			$$.tipo = constante_tipo_default;
		}
		| //MESMO PROBLEMA DO BLOCO REPETIDO NO FINAL!
		{
			$$.traducaoDeclaracaoDeVariaveis = "";
			$$.traducao = "";
			//$$.label = "";
			//$$.tipo = "";
		}
		;



CASES	: CASE CASES
		{
			$$.traducaoDeclaracaoDeVariaveis = $1.traducaoDeclaracaoDeVariaveis + $2.traducaoDeclaracaoDeVariaveis;
			$$.traducao = $1.traducao + $2.traducao;
			$$.tipo = $2.tipo;
		}
		|
		CASE
		;

CASE	: TK_CASE E ':' COMANDO
		{
			if($2.estruturaDoConteudo != constante_estrutura_tipoPrimitivo)
			{
				//dispara erro ...
			}
			//Regra TERMO possui produção que leva em ID, o que não pode.
			//constante_estrutura_variavel
			//$2.label.find(prefixo_variavel_usuario) == std::string::npos
			if( ($2.tipo == constante_tipo_inteiro || $2.tipo == constante_tipo_caracter) &&
				$2.estruturaDoConteudo == constante_estrutura_variavel){

				pair<string,int> tagCaseENumProx = gerarNovaTagSwitch(true);
				string proxCase = tag_case_inicio + to_string(tagCaseENumProx.second);

				//Para referenciar o inicio do teste da condição de cada case. Serve como controle para quando devemos executar
				//todos os cases quando algo for verdadeiro.
				pair<string,string> condicaoCase = gerarNovaTagCondicaoCase();
				string proxCondicaoCase = tag_condicao_case + condicaoCase.second;

				//Gerar primeira label que receberá o resultado da condição de igualdade.
				$$.label = gerarNovaVariavel();
				//Gerar segunda label que receberá a negação da condição de igualdade.
				string tempIrProxCondCase = gerarNovaVariavel();

				$$.traducaoDeclaracaoDeVariaveis = $2.traducaoDeclaracaoDeVariaveis + $4.traducaoDeclaracaoDeVariaveis +
													"\t" + constante_tipo_inteiro + " " + $$.label + ";\n" +
													"\t" + constante_tipo_inteiro + " " + tempIrProxCondCase + ";\n";
				$$.tipo = $2.tipo;

				//Adicionar a tag do inicio do case antes do comando em si.
				$4.traducao = "\t" + tagCaseENumProx.first + ":\n" + $4.traducao +
													"\t" + "goto " + proxCase + ";\n";

				$$.traducao = "\t" + condicaoCase.first + ":\n" +
								$2.traducao + "\t" + $$.label + " = " + tarja_variavel + " == " + $2.label + ";\n" +
								"\t" + tempIrProxCondCase + " = " + "!" + $$.label + ";\n" +
								"\t" + "if" + "(" + tempIrProxCondCase + ")\n" +
								"\t\t" + "goto " + proxCondicaoCase + ";\n" +
								$4.traducao; //+
								//"\t" + "goto " + proxCase + ":\n"; //+
								//"\t" + "goto " + tarja_tagFim + ";\n";
			}else{
				yyerror(MSG_ERRO_TIPO_ID_SWITCH_CASE_INVALIDO);
			}
		}
		;

E_BREAK_CONTINUE	: TK_BREAK
					{
						string salvadorDaPatria = "\t";
						if(!pilhaFimVazia()){
							$$.traducao = salvadorDaPatria + "goto " + obterTopoPilhaFim() + ";\n";
						}else{
							//dispara erro...
							yyerror(MSG_ERRO_BREAK_NAO_PERMITIDO);
						}
					}
					|
					TK_CONTINUE
					{
						string salvadorDaPatria = "\t";
						if(!pilhaInicioVazia()){
							$$.traducao = salvadorDaPatria + "goto " + obterTopoPilhaInicio() + ";\n";
						}else{
							//dispara erro...
							yyerror(MSG_ERRO_CONTINUE_NAO_PERMITIDO);
						}
					}
					;

%%

#include "lex.yy.c"

DADOS_VARIAVEL d;

std::map<string, DADOS_VARIAVEL> tabelaDeVariaveis;
extern int yylineno; //Define a linha atual do arquivo fonte.

int yyparse();

int main( int argc, char* argv[] )
{
	conta = 0;
	mapaTipos = criarMapa();
	inicializarMapaDeContexto();
	//inicializarMapaDeStrings();
	//PARA O DEBUG
	//yydebug = 1;
	yyparse();



	return 0;
}

ATRIBUTOS tratarExpressaoAritmetica(string op, ATRIBUTOS dolar1, ATRIBUTOS dolar3)
{
	if(dolar1.tipo == constante_tipo_funcao){
		dolar1 = tratarFuncaoEmExpressaoOuAtribuicao(dolar1);
	}

	if(dolar3.tipo == constante_tipo_funcao){
		dolar3 = tratarFuncaoEmExpressaoOuAtribuicao(dolar3);
	}

	ATRIBUTOS dolarDolar;

	dolarDolar.label = gerarNovaVariavel();
	dolarDolar.traducaoDeclaracaoDeVariaveis = dolar1.traducaoDeclaracaoDeVariaveis + dolar3.traducaoDeclaracaoDeVariaveis;
	dolarDolar.traducao = dolar1.traducao + dolar3.traducao;
	string resultado = getTipoResultante(dolar1.tipo, dolar3.tipo, op);

	string label_old = dolarDolar.label;

	if(resultado == constante_erro)
	{
		string params[3] = {op,dolar1.tipo, dolar3.tipo};
		yyerror(montarMensagemDeErro(MSG_ERRO_OPERACAO_PROIBIDA_ENTRE_TIPOS, params, 3));
		dolarDolar.tipo = constante_erro;
		return dolarDolar;
	}

	/*
	*TODO Tratar conversão para tipo String
	*
	*/
	if(resultado == constante_tipo_string)
	{
		vector<string> vetorTemporarias;
		gerarVetorNovasVariaveis(op, &vetorTemporarias);
		string traducao = realizarOperacaoString(op, &dolarDolar,&dolar1,&dolar3, vetorTemporarias);

		if(traducao == "") //o operador ainda não está implementado. Fiz assim para não alterar no mapa, vou apagar o if
		{
			string params[3] = {op,dolar1.tipo, dolar3.tipo};
			yyerror(montarMensagemDeErro(MSG_ERRO_OPERACAO_PROIBIDA_ENTRE_TIPOS	, params, 3));
			dolarDolar.tipo = constante_erro;
			return dolarDolar;

		}

		dolarDolar.traducao = dolarDolar.traducao + traducao;
		dolarDolar.traducaoDeclaracaoDeVariaveis = dolarDolar.traducaoDeclaracaoDeVariaveis + realizarTraducaoDeclaracaoOperacaoAritmeticaString(op, &dolarDolar, &dolar1,&dolar3,vetorTemporarias);

	}

	else
	{
		if(dolar1.tipo == dolar3.tipo) //se não houver necessidade de conversão
		{
			//cout << "label0\n";
			dolarDolar.traducao = dolarDolar.traducao + "\t" + dolarDolar.label + " = " + dolar1.label + " " + op + " " + dolar3.label + ";\n";
			dolarDolar.traducaoDeclaracaoDeVariaveis = dolarDolar.traducaoDeclaracaoDeVariaveis + dolar1.tipo + " " + dolarDolar.label + ";\n";
		}

		else if(dolar1.tipo != resultado)
		{
			//cout << "label1\n";
			dolarDolar.traducao = dolarDolar.traducao + "\t" + dolarDolar.label + " = " +"(" + resultado + ")" + dolar1.label + ";\n";
			dolarDolar.label = gerarNovaVariavel();
			dolarDolar.traducaoDeclaracaoDeVariaveis = dolarDolar.traducaoDeclaracaoDeVariaveis + resultado + " " + label_old +  ";\n" + resultado + " " + dolarDolar.label +  ";\n";
			dolarDolar.traducao = dolarDolar.traducao + "\t" + dolarDolar.label + " = " + label_old + " " + op + " " + dolar3.label + ";\n";
		}
		else if(dolar3.tipo != resultado)
		{
			//cout << "label3\n";
			dolarDolar.traducao = dolarDolar.traducao + "\t" + dolarDolar.label + " = " +"(" + resultado + ")" + dolar3.label + ";\n";
			dolarDolar.label = gerarNovaVariavel();
			dolarDolar.traducaoDeclaracaoDeVariaveis = dolarDolar.traducaoDeclaracaoDeVariaveis + resultado + " " + label_old +  ";\n" + resultado + " " + dolarDolar.label +  ";\n";
			dolarDolar.traducao = dolarDolar.traducao + "\t" + dolarDolar.label + " = " + dolar1.label + " " + op + " " + label_old + ";\n";

		}

	}

	dolarDolar.tipo = resultado;
	return dolarDolar;
}

ATRIBUTOS tratarExpressaoAritmeticaComposta(string op, ATRIBUTOS dolar1, ATRIBUTOS dolar3)
{
	if(dolar1.estruturaDoConteudo != constante_estrutura_variavel){
		string p[1] = {op};
		yyerror(montarMensagemDeErro(MSG_ERRO_VALOR_A_ESQUERDA_DE_OPERADOR_COPOSTO_PRECISA_SER_VARIAVEL, p, 1));
	}

	if(dolar3.tipo == constante_tipo_funcao){
		dolar3 = tratarFuncaoEmExpressaoOuAtribuicao(dolar3);
	}

	ATRIBUTOS dolarDolar;
	string operadorSimples = removerSimboloIgualdade(op);
	dolarDolar = tratarExpressaoAritmetica(operadorSimples, dolar1, dolar3);
	dolarDolar.traducao += "\t" + dolar1.label +  " = " + dolarDolar.label + ";\n";
	return dolarDolar;

}

ATRIBUTOS tratarExpressaoLogicaUnaria(string op, ATRIBUTOS dolar2)
{
	if(dolar2.tipo == constante_tipo_funcao){
		dolar2 = tratarFuncaoEmExpressaoOuAtribuicao(dolar2);
	}

	ATRIBUTOS dolarDolar;
	if(dolar2.tipo == constante_tipo_booleano)
	{
		dolarDolar.traducaoDeclaracaoDeVariaveis = dolar2.traducaoDeclaracaoDeVariaveis;
		string tipo = constante_tipo_inteiro;
		dolarDolar.label = gerarNovaVariavel();
		dolarDolar.traducaoDeclaracaoDeVariaveis = dolarDolar.traducaoDeclaracaoDeVariaveis + "\t" + tipo + " " + dolarDolar.label + ";\n";
		dolarDolar.traducao = dolar2.traducao;
		dolarDolar.traducao = dolarDolar.traducao + "\t\t" + dolarDolar.label + " = " + op + " "+ dolar2.label + ";\n";
		dolarDolar.tipo = constante_tipo_booleano;
		return dolarDolar;
	}else{
		yyerror(MSG_ERRO_OPERADOR_LOGICO_COM_OPERANDOS_NAO_BOOLEAN);
	}
}

ATRIBUTOS tratarExpressaoLogicaBinaria(string op, ATRIBUTOS dolar1, ATRIBUTOS dolar3)
{
	if(dolar1.tipo == constante_tipo_funcao){
		dolar1 = tratarFuncaoEmExpressaoOuAtribuicao(dolar1);
	}

	if(dolar3.tipo == constante_tipo_funcao){
		dolar3 = tratarFuncaoEmExpressaoOuAtribuicao(dolar3);
	}

	ATRIBUTOS dolarDolar;
	if(dolar1.tipo == constante_tipo_booleano && dolar3.tipo == constante_tipo_booleano){
		dolarDolar.label = gerarNovaVariavel();
		dolarDolar.traducaoDeclaracaoDeVariaveis = dolar1.traducaoDeclaracaoDeVariaveis + dolar3.traducaoDeclaracaoDeVariaveis;
		dolarDolar.traducaoDeclaracaoDeVariaveis = dolarDolar.traducaoDeclaracaoDeVariaveis + tipoCodigoIntermediario(constante_tipo_booleano) + " " + dolarDolar.label + ";\n";
		dolarDolar.traducao = dolar1.traducao + dolar3.traducao;
		dolarDolar.traducao = dolarDolar.traducao + "\t\t" + dolarDolar.label + " = " + dolar1.label + " " + op + " " + dolar3.label + ";\n";
		dolarDolar.tipo = constante_tipo_booleano;
		return dolarDolar;
	}
	else{
		yyerror(MSG_ERRO_OPERADOR_LOGICO_COM_OPERANDOS_NAO_BOOLEAN);
	}
}

ATRIBUTOS tratarExpressaoLogicaComposta(string op, ATRIBUTOS dolar1, ATRIBUTOS dolar3)
{
	if(dolar1.estruturaDoConteudo != constante_estrutura_variavel){
		string p[1] = {op};
		yyerror(montarMensagemDeErro(MSG_ERRO_VALOR_A_ESQUERDA_DE_OPERADOR_COPOSTO_PRECISA_SER_VARIAVEL, p, 1));
	}

	if(dolar3.tipo == constante_tipo_funcao){
		dolar3 = tratarFuncaoEmExpressaoOuAtribuicao(dolar3);
	}

	ATRIBUTOS dolarDolar;
	string operadorSimples = removerSimboloIgualdade(op);
	dolarDolar = tratarExpressaoLogicaBinaria(operadorSimples, dolar1, dolar3);
	dolarDolar.traducao += "\t" + dolar1.label +  " = " + dolarDolar.label + ";\n";
	return dolarDolar;

}

ATRIBUTOS tratarExpressaoRelacional(string op, ATRIBUTOS dolar1, ATRIBUTOS dolar3)
{
	if(dolar1.tipo == constante_tipo_funcao){
		dolar1 = tratarFuncaoEmExpressaoOuAtribuicao(dolar1);
	}

	if(dolar3.tipo == constante_tipo_funcao){
		dolar3 = tratarFuncaoEmExpressaoOuAtribuicao(dolar3);
	}

	ATRIBUTOS dolarDolar;
	string resultado = getTipoResultante(dolar1.tipo, dolar3.tipo,op);
	string operador = op;

	if(resultado == constante_erro)
	{

		string params[3] = {op, dolar1.tipo, dolar3.tipo};
		yyerror(montarMensagemDeErro(MSG_ERRO_OPERACAO_PROIBIDA_ENTRE_TIPOS, params, 3));
		dolarDolar.tipo = constante_erro;
		return dolarDolar;
	}

	if(resultado == constante_tipo_string)
	{
		vector<string> vetorTemporarias;
		gerarVetorNovasVariaveis(op, &vetorTemporarias);
		string traducao = realizarOperacaoString(op, &dolarDolar,&dolar1,&dolar3, vetorTemporarias);

		if(traducao == "") //o operador ainda não está implementado. Fiz assim para não alterar no mapa, vou apagar o if
		{
			string params[3] = {op,dolar1.tipo, dolar3.tipo};
			yyerror(montarMensagemDeErro(MSG_ERRO_OPERACAO_PROIBIDA_ENTRE_TIPOS	, params, 3));
			dolarDolar.tipo = constante_erro;
			return dolarDolar;

		}

		dolarDolar.traducao = dolarDolar.traducao + traducao;
		dolarDolar.traducaoDeclaracaoDeVariaveis = dolarDolar.traducaoDeclaracaoDeVariaveis + realizarTraducaoDeclaracaoOperacaoRelacionalString(op, &dolarDolar, &dolar1,&dolar3, vetorTemporarias);
		dolarDolar.label = vetorTemporarias.back(); //Pega o último elemento.

	}

	else
	{
		dolarDolar.label = gerarNovaVariavel();
		dolarDolar.traducaoDeclaracaoDeVariaveis += dolar1.traducaoDeclaracaoDeVariaveis + dolar3.traducaoDeclaracaoDeVariaveis;
		dolarDolar.traducao = dolar1.traducao + dolar3.traducao;
		dolarDolar.traducaoDeclaracaoDeVariaveis = dolarDolar.traducaoDeclaracaoDeVariaveis + tipoCodigoIntermediario(constante_tipo_booleano) + " " + dolarDolar.label + ";\n";



		if(dolar1.tipo == dolar3.tipo)
		{
			if(dolar1.tipo == constante_tipo_caracter) //se char,ambos são convertidos pra int
			{
				dolarDolar.traducao = dolarDolar.traducao + "\t" + dolarDolar.label + " = " +"(" + resultado + ")" + dolar1.label + ";\n";

				//dolar1.label = dolarDolar.label;
				string novaVariavel = gerarNovaVariavel();

				dolarDolar.traducaoDeclaracaoDeVariaveis = dolarDolar.traducaoDeclaracaoDeVariaveis + resultado + " " + novaVariavel + ";\n";
				dolarDolar.traducao = dolarDolar.traducao + "\t" + novaVariavel + " = " +"(" + resultado + ")" + dolar3.label + ";\n";
				dolar3.label = novaVariavel;
			}

		}

		else
		{
			string varConvert = gerarNovaVariavel();
			dolarDolar.traducaoDeclaracaoDeVariaveis = dolarDolar.traducaoDeclaracaoDeVariaveis + tipoCodigoIntermediario(resultado) + " " + varConvert + ";\n";

			if(dolar1.tipo != resultado)
			{
				dolarDolar.traducao = dolarDolar.traducao + "\t" + varConvert + " = " +"(" + tipoCodigoIntermediario(resultado) + ")" + dolar1.label + ";\n";

				dolar1.label = varConvert;
			}

			else if(dolar3.tipo != resultado)
			{
				dolarDolar.traducao = dolarDolar.traducao + "\t" + varConvert + " = " +"(" + tipoCodigoIntermediario(resultado) + ")" + dolar3.label + ";\n";
				dolar3.label = varConvert;

			}

		}

		dolarDolar.traducao = dolarDolar.traducao + "\t\t" + dolarDolar.label + " = " + dolar1.label +" "+ op +" "+ dolar3.label + ";\n";
	}



	dolarDolar.tipo = constante_tipo_booleano;


	return dolarDolar;

}


//reutilizada na criação do nome da funcao ... funcao passa o parametro tipo que não é passado nas demais
//TK_PALAVRA_VAR TK_ID ';'
ATRIBUTOS tratarDeclaracaoSemAtribuicao(ATRIBUTOS dolar2, string tipo){

	ATRIBUTOS dolarDolar;

	if(variavelJaDeclarada(dolar2.label, false)){
		//mensagem de erro dupla declaração
		string params[1] = {dolar2.label};
		yyerror(montarMensagemDeErro(MSG_ERRO_DUPLA_DECLARACAO_DE_VARIAVEL, params, 1));
	}

	else
	{
		incluirNoMapa(dolar2.label,0, tipo);
		dolarDolar.label = dolar2.label;
		if(tipo == "")
			dolarDolar.traducaoDeclaracaoDeVariaveis = construirDeclaracaoProvisoriaDeInferenciaDeTipo(dolar2.label);
	}

	return dolarDolar;

}

//TK_PALAVRA_VAR TK_ID '=' VALOR_ATRIBUICAO ';'
ATRIBUTOS tratarDeclaracaoComAtribuicao(ATRIBUTOS dolar2, ATRIBUTOS dolar4)
{
	ATRIBUTOS dolarDolar;

	if(variavelJaDeclarada(dolar2.label, false))
	{
		//mensagem de erro dupla declaração
		string params[1] = {dolar2.label};
		yyerror(montarMensagemDeErro(MSG_ERRO_DUPLA_DECLARACAO_DE_VARIAVEL, params, 1));
	}
	else //Você cria a variável e inclui no mapaDeContexto.
	{
		//cout << "Entrou no else: \n\n\n";
		if(ehTipoNaoAtribuivel(dolar4.tipo, dolar4.estruturaDoConteudo)){
			string params[1] = {dolar2.label};
			yyerror(montarMensagemDeErro(MSG_ERRO_VALOR_ATRIBUIDO_NAO_PODE_SER_ATRIBUIDO, params, 1));
		}

		if(dolar4.tipo == constante_tipo_funcao){
			dolar4 = tratarFuncaoEmExpressaoOuAtribuicao(dolar4);
		}

		int tamanho = 0;

		if(!acessoArray)
			incluirNoMapa(dolar2.label,dolar4.tamanho, dolar4.tipo,tipoArray,valoresReaisDim,pilhaTamanhoDimensoesArray,dolar4.ehDinamica);
		else
			incluirNoMapa(dolar2.label,dolar4.tamanho, tipoArray);

		string tipo = dolar4.tipo;
		string label = recuperarNomeTraducao(dolar2.label, dolar2.escopoDeAcesso);

		//meramente para leitura do código intermediário
		string labelPrefix = prefixo_variavel_usuario;
		labelPrefix = labelPrefix + dolar2.label;


		if(tipo == constante_tipo_booleano)
			tipo = constante_tipo_inteiro;

		if(tipo == constante_tipo_string)
		{
			if(dolar4.ehDinamica)
			{
					tipo = constante_tipo_caracter;
					dolarDolar.traducaoDeclaracaoDeVariaveis = dolar4.traducaoDeclaracaoDeVariaveis + tipo + " * " + label+ "; //" + labelPrefix + "\n";

					//TENTATIVA ATRIBUICAO COM MALLOC
					//dolarDolar.traducao = dolar4.traducao + "\t" + label +" = (char*) malloc(sizeof(" + dolar4.label + "));\n\t" + montarCopiarString(label, dolar4.label) + ";\n";

					//TENTATIVA ATRIBUINDO PONTEIRO
					dolarDolar.traducao = dolar4.traducao + "\t" + label +" = "+ dolar4.label + "; //" + labelPrefix + "\n";

			}
			else
			{
				tipo = constante_tipo_caracter;
				dolarDolar.traducaoDeclaracaoDeVariaveis = dolar4.traducaoDeclaracaoDeVariaveis + tipo + " " + label + "[" + to_string(dolar4.tamanho) + "]; //" + labelPrefix + "\n";
				dolarDolar.traducao = dolar4.traducao + montarCopiarString(label, dolar4.label) + ";\n";

			}

		}
		else if(tipo == constante_tipo_array)
		{
			DADOS_VARIAVEL aux;
			pair<string,string> resultTraducao;

			if(acessoArray)
			{
				//cout << "CASO: var a = livia[x,y]" << endl << endl;

				dolarDolar.traducaoDeclaracaoDeVariaveis =  dolar4.traducaoDeclaracaoDeVariaveis +
															tipoCodigoIntermediario(tipoArray) + " " + label +
															"; //" + labelPrefix + "\n";
				/*
				dolarDolar.traducao = dolar4.traducao + "\t" + label + " = " +
															recuperarNomeTraducao(dolar4.label) + "[" + dolar4.labelIndice + "];\n"; //nomeIdOriginal
				*/
				dolarDolar.traducao = dolar4.traducao + "\t" + label + " = " + dolar4.labelAux + ";\n";
				dolar4.tipo = tipoArray;
			}
			else
			{
				if(dolar4.estruturaDoConteudo != constante_estrutura_criacaoArrayPreDefinido)
				{
						//cout << "CASO: var a = tipo[x,y]" << endl << endl;
						aux = recuperarDadosVariavel(dolar2.label);

						if(dolar4.ehDinamica)
							resultTraducao = traducaoCriacaoArray(label,&aux.pilhaTamanhoDimensoesArray);
						else
							resultTraducao = traducaoCriacaoArray(label,NULL,dolar4.valorNum);

						dolarDolar.traducaoDeclaracaoDeVariaveis = dolar4.traducaoDeclaracaoDeVariaveis +
																	tipoCodigoIntermediario(tipoArray) + " *" +
																	label + "; //" + labelPrefix + "\n" + resultTraducao.first;
																	//tipoArrayCodInterm
						dolarDolar.traducao = dolar4.traducao + resultTraducao.second;
				}
				else //Definição de elementos pré definidos.
				{
						//cout << "CASO: var a = [x1,x2,x3,x4,...xn] << endl << endl"

						//cout << obterDimInteiraArray(0).first << endl << endl;
						resultTraducao = traducaoCriacaoArray(label,&labelsDosElementosLidos,stoi(obterDimInteiraArray(0).first),true);

						dolarDolar.traducaoDeclaracaoDeVariaveis = dolar4.traducaoDeclaracaoDeVariaveis + tipoCodigoIntermediario(tipoArray) + " *" + label +
																										"; //" + labelPrefix + "\n" + resultTraducao.first;
						dolarDolar.traducao = dolar4.traducao + resultTraducao.second;
				}

				adicionarTraducaoComandosFree(label);
			}

			resetarTamanhoDimensoesArray();
			resetarVarGlobaisArray();
		}

		else
		{
			dolarDolar.traducaoDeclaracaoDeVariaveis = dolar4.traducaoDeclaracaoDeVariaveis + tipo + " " + label + "; //" + labelPrefix + "\n";
			dolarDolar.traducao = dolar4.traducao + "\t" + label + " = " + dolar4.label + ";\n";
		}

		dolarDolar.traducaoDeclaracaoDeVariaveis = dolarDolar.traducaoDeclaracaoDeVariaveis;
		dolarDolar.label = label;
		dolarDolar.tipo = dolar4.tipo;
		dolarDolar.ehDinamica = dolar4.ehDinamica;
		dolarDolar.tamanho = dolar4.tamanho;
	}


	return dolarDolar;

}

//ID '=' VALOR_ATRIBUICAO ';'
ATRIBUTOS tratarAtribuicaoVariavel(ATRIBUTOS dolar1, ATRIBUTOS dolar3, bool ehDinamica)
{
	ATRIBUTOS dolarDolar;
	string tipo = "";
	int tamanho = 0;
	string labelRecuperada = recuperarNomeTraducao(dolar1.label);

	bool nuncaAtribuida = false;
	string tipoDolar1 = "";
	string tipoDolar3 = "";
	string swap = "";

	if(dolar1.label != dolar3.label)
	{
		if(ehTipoNaoAtribuivel(dolar3.tipo, dolar3.estruturaDoConteudo)){
			string params[1] = {dolar1.label};
			yyerror(montarMensagemDeErro(MSG_ERRO_VALOR_ATRIBUIDO_NAO_PODE_SER_ATRIBUIDO, params, 1));
		}

		if(dolar1.tipo == constante_tipo_array && dolar1.acessoArray)
		{
			swap = dolar1.label; //label indexado
			dolar1.label = dolar1.labelAux; //label original
			dolar1.labelAux = swap; //label indexado
		}


		if(dolar3.tipo == constante_tipo_funcao){
			dolar3 = tratarFuncaoEmExpressaoOuAtribuicao(dolar3);
		}

		DADOS_VARIAVEL metaData;
		if(dolar1.escopoDeAcesso >= 0){
			metaData = recuperarDadosVariavel(dolar1.label, dolar1.escopoDeAcesso);
		}
		else{
			metaData = recuperarDadosVariavel(dolar1.label);
		}

		if(metaData.tipo == "") //A variável não tipo, ou seja, já existe, mas sem valor. CASO ARRAY '=' E NUNCA ENTRARÁ AQUI
		{
			nuncaAtribuida = true;
			//isso aqui também pode causar problema no futuro devido as lacunas
			metaData.tipo = dolar3.tipo;
			//atualizarNoMapa(metaData);
			tipo = metaData.tipo;
			if(tipo == constante_tipo_booleano)
			{
				tipo = constante_tipo_inteiro;
				tipo = "\t" + tipo;
			}

			if(tipo == constante_tipo_string)
			{
				metaData.tamanho = dolar3.tamanho;
			}

			if(tipo == constante_tipo_array)
			{
				//tipo = constante_tipo_array;

				if(dolar3.acessoArray) // Caso a = livia[x,y] // 'a' sem valor
				{
					tipo = dolar3.tipoArray;
					tipoDolar1 = dolar3.tipoArray;
					metaData.tipo = dolar3.tipoArray;
				}
				else
				{
					metaData.pilhaTamanhoDimensoesArray = pilhaTamanhoDimensoesArray;
					metaData.valoresReaisDim = valoresReaisDim;
					metaData.tipoArray = tipoArray;
					metaData.foiCriadoDinamicamente = dolar3.ehDinamica;
				}
			}

			metaData.ehDinamica = ehDinamica;
			if(dolar1.escopoDeAcesso >= 0){
				adicionarDefinicaoDeTipo(dolar1.label, tipo, dolar3.tamanho,ehDinamica, dolar1.escopoDeAcesso,tipoArray);
				atualizarNoMapa(metaData, dolar1.escopoDeAcesso);
			}
			else{
				adicionarDefinicaoDeTipo(dolar1.label, tipo,dolar3.tamanho,ehDinamica,numeroEscopoAtual,tipoArray);
				atualizarNoMapa(metaData);
			}

			dolar1.tipo = dolar3.tipo;
		}
		else //A variável tem tipo, ou seja, já existe e tem um valor.
		{
			//CASO ESPECIFICO DO ARRAY
			if(dolar1.tipo != constante_tipo_array && dolar3.acessoArray) //CASO: a = livia[x,y] //'a' tem valor
			{
			//	cout << "//CASO: a = livia[x,y] //'a' tem valor ---> Preparar pra entrar no ==" << endl << endl;

				if(dolar1.tipo != dolar3.tipoArray)
				{
					//dispara erro...
					yyerror("Tipo lado esquerdo e direito incompatíveis. CASO: a = livia[x,y] //'a' tem valor");
				}
				else
				{
					tipoDolar1 = dolar1.tipo;
					dolar1.tipo = constante_tipo_array; //Para entrar no if do caso array e ser tratado (atribuicao provisoria);
				}
			}

			if(dolar1.tipo == constante_tipo_array && dolar3.tipo != constante_tipo_array) //CASO: livia[x,y] = a|30|2.6
			{
				//cout << "CASO: livia[x,y] = a|30|2.6 ---> Preparar pra entrar no ==" << endl << endl;

				if(dolar1.tipoArray != dolar3.tipo)
				{
					//dispara erro...
					yyerror("Tipo lado esquerdo e direito incompatíveis. Caso livia[x,y] = a|30|2.6");
				}
				else
				{
					tipoDolar3 = dolar3.tipo;
					dolar3.tipo = constante_tipo_array; //Para entrar no if do caso array e ser tratado (atribuicao provisoria);
				}
			}

			if(dolar1.acessoArray && dolar3.acessoArray) //Caso livia[x,y] = braida[u,v]
			{
		//		cout << "CASO: livia[x,y] = braida[u,v] ---> Preparar pra entrar no ==" << endl << endl;

				if(dolar1.tipoArray != dolar3.tipoArray)
				{
					//dispara erro...
					yyerror("Tipo lado esquerdo e direito incompatíveis. Caso livia[x,y] = braida[u,v]");
				}
			}
		}

//provavelmente ainda há lacunas, mas vamos ignorar por enquanto
		if(dolar1.tipo == dolar3.tipo)
		{
			dolarDolar.traducaoDeclaracaoDeVariaveis = dolar3.traducaoDeclaracaoDeVariaveis;

			if(dolar3.tipo == constante_tipo_string)
				dolarDolar.traducao = dolar3.traducao + montarCopiarString(labelRecuperada, dolar3.label) + ";\n";
			else if(dolar3.tipo == constante_tipo_array) //CASO ARRAY
			{
				//Caso novo array ---> Varável estava sem valor algum inicialmente. Criação normal.
				if(nuncaAtribuida)
				{
					if(!dolar3.acessoArray) //Criação de novo array.
					{
						//cout << "CASO: a = tipo[x,y] //'a' sem valor" << endl << endl;

						pair<string,string> resultTraducao;

						if(dolar3.estruturaDoConteudo != constante_estrutura_criacaoArrayPreDefinido)
						{
								//pair<string,string> resultTraducao;

								if(ehDinamica)
									resultTraducao = traducaoCriacaoArray(labelRecuperada,&pilhaTamanhoDimensoesArray);
								else
									resultTraducao = traducaoCriacaoArray(labelRecuperada,NULL,dolar3.valorNum);

								dolarDolar.traducaoDeclaracaoDeVariaveis = dolar3.traducaoDeclaracaoDeVariaveis + resultTraducao.first;
								dolarDolar.traducao = dolar3.traducao + resultTraducao.second;
								//adicionarTraducaoComandosFree(labelRecuperada);
						}
						else
						{
//								cout << "CASO: a = [x1,x2,x3,x4,...xn] //'a' sem valor" << endl << endl;

								resultTraducao = traducaoCriacaoArray(labelRecuperada,&labelsDosElementosLidos,stoi(obterDimInteiraArray(0).first),true);

								dolarDolar.traducaoDeclaracaoDeVariaveis = dolar3.traducaoDeclaracaoDeVariaveis + resultTraducao.first;
								dolarDolar.traducao = dolar3.traducao + resultTraducao.second;
						}

						adicionarTraducaoComandosFree(labelRecuperada);
					}
					else //Atribuição de valor dentro do array. // CASO: a = livia[x,y] (a já existe, mas está sem valor.)
					{
	//					cout << "CASO: a = livia[x,y] (a já existe, mas está sem valor.)" << endl << endl << endl;

						dolarDolar.traducaoDeclaracaoDeVariaveis = dolar3.traducaoDeclaracaoDeVariaveis; //TALVEZ MUDE

						/*
						dolarDolar.traducao = dolar3.traducao + "\t" + labelRecuperada + " = " + recuperarNomeTraducao(dolar3.label) +
												"[" + dolar3.labelIndice + "];\n";
						*/
						dolarDolar.traducao = dolar3.traducao + "\t" + labelRecuperada + " = " + dolar3.label + ";\n";
						dolar1.tipo = tipoDolar1;
					}

				}
				//Caso novo array ---> Variável já tinha um array mas deseja trocar pelo novo. Desalocar memória antiga e alocar uma nova.
				else
				{
					if(!dolar1.acessoArray && tipoDolar1 != constante_tipo_array && dolar3.criacaoArray) //Criação de novo array.
					{
						if(metaData.tipoArray != tipoArray)
						{
							//dispara erro...

							//para remover o prefixo só se tiver prefixo
							string strPrefixoVarUsuario = prefixo_variavel_usuario;
							string labelVar;
							if(dolar1.label.find(strPrefixoVarUsuario) == 0)
								labelVar = dolar1.label.replace(0, strPrefixoVarUsuario.length(), "");

							string params[3] = {labelVar, metaData.tipoArray + "[]", tipoArray + "[]"};
							yyerror(montarMensagemDeErro(MSG_ERRO_ATRIBUICAO_DE_TIPOS_DIFERENTES, params, 3));
						}
						else
						{
							pair<string,string> resultTraducao;
							string labelTemp = gerarNovaVariavel();

							if(dolar3.estruturaDoConteudo != constante_estrutura_criacaoArrayPreDefinido)
							{
			//						cout << "CASO: a = tipo[x,y] //'a' com valor e mesmo tipo do array novo" << endl << endl;

									//pair<string,string> resultTraducao;
									//string labelTemp = gerarNovaVariavel();

									if(ehDinamica)
										resultTraducao = traducaoCriacaoArray(labelTemp,&pilhaTamanhoDimensoesArray);
									else
										resultTraducao = traducaoCriacaoArray(labelTemp,NULL,dolar3.valorNum);
							}
							else //Atribuição com array com valores pré-determinados.
							{
				//					cout << "CASO: a = [x1,x2,x3,x4,...xn] //'a' com valor" << endl << endl;

									resultTraducao = traducaoCriacaoArray(labelTemp,&labelsDosElementosLidos,stoi(obterDimInteiraArray(0).first),true);
							}

							dolarDolar.traducaoDeclaracaoDeVariaveis = dolar3.traducaoDeclaracaoDeVariaveis + resultTraducao.first +
																		tipoArrayCodInterm + " *" + labelTemp + ";\n";
							dolarDolar.traducao = dolar3.traducao + resultTraducao.second + "\t" + "free(" + labelRecuperada +
													");\n" + "\t" + labelRecuperada + " = " + labelTemp + ";\n";

							metaData.pilhaTamanhoDimensoesArray = pilhaTamanhoDimensoesArray;
							metaData.valoresReaisDim = valoresReaisDim;

							//Preciso atualizar no Mapa as pilhas das labels das dimensoes e dos valores reais do array na variável.
							if(dolar1.escopoDeAcesso >= 0)
								atualizarNoMapa(metaData, dolar1.escopoDeAcesso);
							else
								atualizarNoMapa(metaData);

						}
					}
					else //Atribuição de valor dentro do array.
					{
						/*Casos:
							a = livia[x,y] // 'a' com valor
							livia[x,y] = braida[u,v];
							livia[x,y] = a | 2.3 | 30 | "ola" | 'a' | true
						*/

						if(!dolar1.acessoArray && dolar3.acessoArray) //a = livia[x,y] // 'a' com valor
						{
		//					cout << "CASO: a = livia[x,y] // 'a' com valor" << endl;

							dolarDolar.traducaoDeclaracaoDeVariaveis = dolar3.traducaoDeclaracaoDeVariaveis;
							/*
							dolarDolar.traducao = dolar3.traducao + "\t" + labelRecuperada + " = " + recuperarNomeTraducao(dolar3.label) +
													"[" + dolar3.labelIndice + "];\n"
							*/
							dolarDolar.traducao = dolar3.traducao + "\t" + labelRecuperada + " = " + dolar3.label + ";\n";
							dolar1.tipo = tipoDolar1;

						}
						else if(dolar1.acessoArray && dolar3.acessoArray) //livia[x,y] = braida[u,v];
						{
				//			cout << "CASO: livia[x,y] = braida[u,v]" << endl;

							dolarDolar.traducaoDeclaracaoDeVariaveis = dolar1.traducaoDeclaracaoDeVariaveis +
																		 dolar3.traducaoDeclaracaoDeVariaveis;
							/*
							dolarDolar.traducao = dolar1.traducao + dolar3.traducao + "\t" + recuperarNomeTraducao(dolar1.label) + "[" +
													dolar1.labelIndice + "] = " + recuperarNomeTraducao(dolar3.label) + "[" +
													dolar3.labelIndice + "];\n";
							*/
							dolarDolar.traducao = dolar1.traducao + dolar3.traducao + "\t" + dolar1.labelAux + " = " + dolar3.label + ";\n";
							//dolar1.tipo = tipoDolar1;
						}
						else if(dolar1.acessoArray && !dolar3.acessoArray) //livia[x,y] = a | 2.3 | 30 | "ola" | 'a' | true
						{
				//			cout << "CASO: livia[x,y] = a | 2.3 | 30 | 'ola' | 'a' | true" << endl;

							dolarDolar.traducaoDeclaracaoDeVariaveis = dolar1.traducaoDeclaracaoDeVariaveis +
																		 dolar3.traducaoDeclaracaoDeVariaveis;
							/*
							dolarDolar.traducao = dolar1.traducao + dolar3.traducao + "\t" + recuperarNomeTraducao(dolar1.label) +
													"[" + dolar1.labelIndice + "] = " + recuperarNomeTraducao(dolar3.label) + ";\n";
							*/
							dolarDolar.traducao = dolar1.traducao + dolar3.traducao + "\t" + dolar1.labelAux + " = " +
																		recuperarNomeTraducao(dolar3.label) + ";\n";
							//dolar1.tipo = tipoDolar1;
						}
					}

				}

				resetarTamanhoDimensoesArray();
				resetarVarGlobaisArray();

			}
			else
				dolarDolar.traducao = dolar3.traducao + "\t" + labelRecuperada + " = " + dolar3.label + ";\n";
		}
		else
		{

			string strPrefixoVarUsuario = prefixo_variavel_usuario;
			string labelVar = dolar1.label;
			//para remover o prefixo só se tiver prefixo
			if(dolar1.label.find(strPrefixoVarUsuario) == 0)
				labelVar = dolar1.label.replace(0, strPrefixoVarUsuario.length(), "");

			string params[3] = {labelVar, dolar1.tipo, dolar3.tipo};
			yyerror(montarMensagemDeErro(MSG_ERRO_ATRIBUICAO_DE_TIPOS_DIFERENTES, params, 3));
		}

		dolarDolar.label = dolar1.label;
		dolarDolar.tipo = dolar1.tipo;
		dolarDolar.tamanho = dolar3.tamanho;
		dolarDolar.ehDinamica = ehDinamica;
		dolarDolar.escopoDeAcesso = dolar1.escopoDeAcesso;

	}
	else //TRATAR CASO ESPECÍFICO DO ARRAY: livia[2,3] = livia[0,0];
	{

		/*
		if(dolar1.acessoArray && dolar3.acessoArray)
		{
			string atribuicao = " = ";

			dolarDolar.traducaoDeclaracaoDeVariaveis = dolar1.traducaoDeclaracaoDeVariaveis + dolar3.traducaoDeclaracaoDeVariaveis;
			dolarDolar.traducao = dolar1.traducao + dolar3.traducao + "\t" + labelRecuperada + "[" + dolar1.labelIndice + "]" +
									atribuicao + labelRecuperada + "[" + dolar3.labelIndice + "];\n";
			dolarDolar.tipo = constante_tipo_array;
			dolarDolar.label = dolar1.label;
			dolarDolar.escopoDeAcesso = dolar1.escopoDeAcesso;
		}
		else
		{
			dolarDolar = dolar3;
		}
		*/

		dolarDolar = dolar3;
	}


	return dolarDolar;

}

ATRIBUTOS verificarPossibilidadeDeAplicarFuncaoEmExpressao(ATRIBUTOS dolarx)
{
	if(verificarQtdDeRetornos(recuperarNomeTraducao(dolarx.label, dolarx.escopoDeAcesso)) != 1)
	{
		dolarx.tipo = constante_erro;
		string p[1] = {dolarx.label};
		dolarx.label = montarMensagemDeErro(MSG_ERRO_FUNCAO_COM_MAIS_DE_UM_RETORNO_NAO_PODE_SER_OPERADA_OU_ATRIBUIDA, p, 1);
		return dolarx;
	}

	DADOS_VARIAVEL retorno = recuperarDadosRetornoDaFuncaoParaOperacao(recuperarNomeTraducao(dolarx.label, dolarx.escopoDeAcesso));
	dolarx.tipo = retorno.tipo;
	dolarx.label = retorno.nomeTraducao;
	if(retorno.tipo == constante_tipo_string)
	{
		dolarx.ehDinamica = retorno.ehDinamica;
		dolarx.tamanho = retorno.tamanho;
	}
	return dolarx;
}

ATRIBUTOS tratarFuncaoEmExpressaoOuAtribuicao(ATRIBUTOS dolarx){
	if(dolarx.tipo == constante_tipo_funcao && dolarx.estruturaDoConteudo == constante_estrutura_funcao)
		yyerror(MSG_ERRO_DECLARACAO_DE_FUNCAO_NAO_EH_OPERAVEL_OU_ATRIBUIVEL);//declarar erro

	if(dolarx.tipo == constante_tipo_funcao)
	{
		dolarx = verificarPossibilidadeDeAplicarFuncaoEmExpressao(dolarx);
		if(dolarx.tipo == constante_erro)
			yyerror(dolarx.label);
	}
	return dolarx;
}

bool verificarPossibilidadeDeConversaoExplicita(string tipoOrigem, string tipoDestino){

	return !(
					tipoOrigem == constante_tipo_booleano ||
					tipoOrigem == constante_tipo_array ||
					tipoDestino == constante_tipo_array ||
					tipoOrigem == constante_tipo_string ||
					tipoDestino == constante_tipo_string
					);
}

bool ehTipoInputavel(string tipo){
	if(
		tipo == constante_tipo_funcao ||
		tipo == constante_tipo_array
		)
		return false;
	return true;
}

bool ehTipoNaoAtribuivel(string tipo, string estruturaDoConteudo = ""){
	if(
		//temporariamente não permite atribuir declaração de váriavel
		(tipo == constante_tipo_funcao && estruturaDoConteudo == constante_estrutura_funcao)
		)
		return true;
	return false;
}


void yyerror( string MSG )
{
	cout << "Linha " << yylineno << ": " << MSG << endl;
	exit (0);
}
