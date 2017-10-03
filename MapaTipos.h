
#include <iostream>
#include <map>
#include <string>

#include "ConstanteTipos.h"


using namespace std;
using namespace ConstanteTipos;


namespace MapaTiposLib
{
	

	//mapa formado por chave=tipo1_tipo2_operador	valor=resultado
	static map<string, string> mapaTipos;
	
	
	
	
	
	string gerarChaveFinal(string tipo1, string tipo2, string operador)
	{
		return tipo1 + "_" + tipo2 + "_" + operador;
	}
	
	
	string getTipoResultante(string tipo1, string tipo2, string operador)
	{
		string chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
		string tipoResultante = mapaTipos[chaveFinal];
		
		if(tipoResultante == "")
		{	
			chaveFinal = gerarChaveFinal(tipo2,tipo1,operador);
			tipoResultante = mapaTipos[chaveFinal];
		}
		
		
		return tipoResultante;
		
		
	}
	
	/*string gerarMensagemErroOperacaoProibida(string tipo1, string tipo2, string operador)
	{
		return "Erro: Não é possível efetuar operação com o operador " + operador + " entre os tipos " + tipo1 + " e " + tipo2;
		
	}*/


	map<string, string> criarMapa()
	{
	
		string tipo1;
		string tipo2;
		string operador;
		string chaveFinal;

		/*****************operações ariméticas******************/
		//********** operadores +, -, * , /
			//soma
			operador = "+";
				
				//inteiro + inteiro
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_inteiro;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));
			
				//inteiro + flutuante
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//inteiro + booleano
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//inteiro + caracter
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));



				//flutuante + flutuante
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//flutuante + booleano
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//flutuante + caracter
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//booleano + booleano
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_booleano;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//booleano + caracter
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));
				
				
				//caracter + caracter
				tipo1 = constante_tipo_caracter;
				tipo2 = constante_tipo_caracter;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


			//subtracao
			operador = "-";
			
				//inteiro + inteiro
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_inteiro;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));
			
				//inteiro + flutuante
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//inteiro + booleano
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//inteiro + caracter
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));



				//flutuante + flutuante
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//flutuante + booleano
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//flutuante + caracter
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//booleano + booleano
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_booleano;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//booleano + caracter
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));
				
				
				//caracter + caracter
				tipo1 = constante_tipo_caracter;
				tipo2 = constante_tipo_caracter;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


			//multiplicação
			operador = "*";
			
				//inteiro + inteiro
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_inteiro;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));
			
				//inteiro + flutuante
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//inteiro + booleano
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//inteiro + caracter
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));



				//flutuante + flutuante
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//flutuante + booleano
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//flutuante + caracter
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//booleano + booleano
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_booleano;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//booleano + caracter
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));
				
				
				//caracter + caracter
				tipo1 = constante_tipo_caracter;
				tipo2 = constante_tipo_caracter;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


			//divisao
			operador = "/";
			
				//inteiro + inteiro
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_inteiro;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));
			
				//inteiro + flutuante
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//inteiro + booleano
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//inteiro + caracter
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));



				//flutuante + flutuante
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//flutuante + booleano
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//flutuante + caracter
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//booleano + booleano
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_booleano;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//booleano + caracter
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));
				
				
				//caracter + caracter
				tipo1 = constante_tipo_caracter;
				tipo2 = constante_tipo_caracter;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


		/*******************************************operações relacionais*******************************************/	

		//********************** operadores <, >, <=, >=, ==, !=
		
		//menor que
			operador = "<";
			
				//inteiro + inteiro
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_inteiro;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));
			
				//inteiro + flutuante
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//inteiro + booleano
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//inteiro + caracter
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));



				//flutuante + flutuante
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//flutuante + booleano
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//flutuante + caracter
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//booleano + booleano
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_booleano;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//booleano + caracter
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));
				
				
				//caracter + caracter
				tipo1 = constante_tipo_caracter;
				tipo2 = constante_tipo_caracter;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));
				
		//maior que
			operador = ">";
			
				//inteiro + inteiro
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_inteiro;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));
			
				//inteiro + flutuante
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//inteiro + booleano
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//inteiro + caracter
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));



				//flutuante + flutuante
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//flutuante + booleano
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//flutuante + caracter
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//booleano + booleano
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_booleano;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//booleano + caracter
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));
				
				
				//caracter + caracter
				tipo1 = constante_tipo_caracter;
				tipo2 = constante_tipo_caracter;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));
				
		//menor ou igual
			operador = "<=";
			
				//inteiro + inteiro
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_inteiro;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));
			
				//inteiro + flutuante
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//inteiro + booleano
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//inteiro + caracter
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));



				//flutuante + flutuante
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//flutuante + booleano
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//flutuante + caracter
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//booleano + booleano
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_booleano;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//booleano + caracter
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));
				
				
				//caracter + caracter
				tipo1 = constante_tipo_caracter;
				tipo2 = constante_tipo_caracter;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));

		//maior ou igual
			operador = ">=";
			
				//inteiro + inteiro
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_inteiro;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));
			
				//inteiro + flutuante
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//inteiro + booleano
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//inteiro + caracter
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));



				//flutuante + flutuante
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//flutuante + booleano
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//flutuante + caracter
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//booleano + booleano
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_booleano;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//booleano + caracter
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));
				
				
				//caracter + caracter
				tipo1 = constante_tipo_caracter;
				tipo2 = constante_tipo_caracter;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));
				
		//igual igual
			operador = "==";
			
				//inteiro + inteiro
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_inteiro;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));
			
				//inteiro + flutuante
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//inteiro + booleano
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//inteiro + caracter
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));



				//flutuante + flutuante
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//flutuante + booleano
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//flutuante + caracter
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//booleano + booleano
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_booleano;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//booleano + caracter
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));
				
				
				//caracter + caracter
				tipo1 = constante_tipo_caracter;
				tipo2 = constante_tipo_caracter;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));
				
		//não igual (diferente)
			operador = "!=";
			
				//inteiro + inteiro
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_inteiro;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));
			
				//inteiro + flutuante
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//inteiro + booleano
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//inteiro + caracter
				tipo1 = constante_tipo_inteiro;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));



				//flutuante + flutuante
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_flutuante;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//flutuante + booleano
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_booleano;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//flutuante + caracter
				tipo1 = constante_tipo_flutuante;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_flutuante));


				//booleano + booleano
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_booleano;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));


				//booleano + caracter
				tipo1 = constante_tipo_booleano;
				tipo2 = constante_tipo_caracter;
				chaveFinal = gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_erro));
				
				
				//caracter + caracter
				tipo1 = constante_tipo_caracter;
				tipo2 = constante_tipo_caracter;
				chaveFinal =  gerarChaveFinal(tipo1,tipo2,operador);
				
				mapaTipos.insert(make_pair(chaveFinal, constante_tipo_inteiro));



		return mapaTipos;


	}
	
	

}


/*namespace MapaTiposLib
{
    struct CelulaMapaTipos
    {
        string tipo1;
        string tipo2;
        string operacao;
        string resultado;
    };


    struct MapaTipos
    {
        int numLinhas;
        int numColunas;
        CelulaMapaTipos ** matrizTipos;

    };


    MapaTipos inicializarMatrizMapa(int numLinhas, int numColunas)
    {
        MapaTipos mapa;

        mapa.numLinhas = numLinhas;
        mapa.numColunas = numColunas;
        
        mapa.matrizTipos = (CelulaMapaTipos **) malloc(sizeof(CelulaMapaTipos) * mapa.numLinhas);
        
        for(int i = 0; i< mapa.numLinhas; i++)
        {
            mapa.matrizTipos[i] = (CelulaMapaTipos *) malloc(sizeof(CelulaMapaTipos) * mapa.numColunas);
        
        }

        return mapa;
    }

    bool adicionarElemento(MapaTipos mapa, CelulaMapaTipos *elemento);

    bool adicionarElemento(MapaTipos mapa,int posLinha, int posColuna, string tipo1, string tipo2, string operacao, string resultado)
    {
        mapa.matrizTipos[posLinha][posColuna].tipo1 = tipo1;
        mapa.matrizTipos[posLinha][posColuna].tipo2 = tipo2;
        mapa.matrizTipos[posLinha][posColuna].operacao = operacao;
        mapa.matrizTipos[posLinha][posColuna].resultado = resultado;
    }

    CelulaMapaTipos acharElementoRetornaCelula(MapaTipos mapa, string tipo1, string tipo2, string operacao)
    {
    	for (int i = 0; i < mapa.numLinhas; i++)
    	{
    		for (int j = 0; j < mapa.numColunas; j++)
    		{
    			if (mapa.matrizTipos[i][j].tipo1 == tipo1 && mapa.matrizTipos[i][j].tipo2 == tipo2 && mapa.matrizTipos[i][j].operacao == operacao)
    			{
    				return mapa.matrizTipos[i][j];
    			}
    		}
    	}

    	//return "";

    }

    string acharElementoRetornaResultado(MapaTipos mapa, string tipo1, string tipo2, string operacao)
    {
    	for (int i = 0; i < mapa.numLinhas; i++)
    	{
    		for (int j = 0; j < mapa.numColunas; j++)
    		{
    			if (mapa.matrizTipos[i][j].tipo1 == tipo1 && mapa.matrizTipos[i][j].tipo2 == tipo2 && mapa.matrizTipos[i][j].operacao == operacao)
    			{
    				return mapa.matrizTipos[i][j].resultado;
    			}
    		}
    	}

    	return "";

    }

    bool removerElemento(CelulaMapaTipos elementoARemover);

    bool removerElemento(int posLinha, int posColuna);

    void imprimirElemento(MapaTipos mapa, int posLinha, int posColuna)
    {
    	
		cout << "Imprimindo elemento: " << posLinha << "  " << posColuna << ":\n";
        cout << mapa.matrizTipos[posLinha][posColuna].tipo1 << "\n";
        cout << mapa.matrizTipos[posLinha][posColuna].tipo2 << "\n";
        cout << mapa.matrizTipos[posLinha][posColuna].operacao << "\n";
        cout << mapa.matrizTipos[posLinha][posColuna].resultado << "\n";

    }

} */
