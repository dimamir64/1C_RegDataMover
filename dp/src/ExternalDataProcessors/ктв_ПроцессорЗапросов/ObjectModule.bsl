// ----------------------------------------------------------
// This Source Code Form is subject to the terms of the
// Mozilla Public License, v.2.0. If a copy of the MPL
// was not distributed with this file, You can obtain one
// at http://mozilla.org/MPL/2.0/.
// ----------------------------------------------------------
// Codebase: https://github.com/ArKuznetsov/RegDataMover/
// ----------------------------------------------------------

#Область ПрограммныйИнтерфейс

// Функция - Выполняет переданный запрос
//
// Параметры:
//  Запрос_Текст					 - Строка			 - Текст запроса
//  Запрос_Параметры				 - ТаблицаЗначений	 - Параметры запроса
//  	Параметр_Имя					 - Строка		 - Имя параметра
//  	Параметр_Тип					 - Строка		 - Тип значения параметра
//  	Параметр_СпособЗаполнения		 - Строка		 - "Значение" - заполняется по значению параметра
//														   "Список" - заполняется из списка значений
//														   "Выражение" - заполняется результатом вычисления выражения
//  	Параметр_Значение				 - Произвольный	 - Значение параметра (для выражений указывается имя выражения
//														   в таблице ПроизвольныеВыражения)
//	ОграничениеВыборки				 - Число			 - Количество строк в результате запроса (0 - без ограничений)
//  ПроизвольныеВыражения			 - ТаблицаЗначений	 - Таблица произвольных выражений
//  	Имя								 - Строка		 - Имя выражения
//  	Код								 - Строка		 - Исполняемый код выражения
//  Параметры						 - Структура		 - Дополнительные параметры, которые могут использоваться в выражениях
//  ВозвращатьТаблицуЗначений		 - Булево			 - Истина - возвращать ТаблицуЗначений
//														   Ложь - возвращать РезультатЗапроса
// 
// Возвращаемое значение:
//   РезультатЗапроса, ТаблицаЗначений		- Результат выполнения запроса
//
Функция ВыполнитьЗапрос(Запрос_Текст
	                  , Запрос_Параметры
	                  , ОграничениеВыборки
	                  , ПроизвольныеВыражения
	                  , Параметры
	                  , ВозвращатьТаблицуЗначений = Истина
	                  , ТекстОшибки = "") Экспорт
	
	Если ОграничениеВыборки = Неопределено ИЛИ ОграничениеВыборки = 0 Тогда
		ТекстЗапроса = Запрос_Текст;
	Иначе
			
		Схема = Новый СхемаЗапроса();
		Попытка
			Схема.УстановитьТекстЗапроса(Запрос_Текст);
		Исключение
			ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			Возврат Неопределено;
		КонецПопытки;
		
		й = Схема.ПакетЗапросов.Количество() - 1;
		
		Пока й >= 0 Цикл
			
			ТекЗапрос = Схема.ПакетЗапросов.Получить(й);
			
			Если НЕ ТипЗнч(ТекЗапрос) = Тип("ЗапросВыбораСхемыЗапроса") Тогда
				й = й - 1;
				Продолжить;
			КонецЕсли;
			
			Если НЕ ПустаяСтрока(ТекЗапрос.ТаблицаДляПомещения) Тогда
				й = й - 1;
				Продолжить;
			КонецЕсли;
			
			Прервать;
		КонецЦикла;
		
		Если НЕ ТипЗнч(ТекЗапрос) = Тип("ЗапросВыбораСхемыЗапроса") Тогда
			ТекстОшибки = "Не обнаружен тест основного запроса!";
			Возврат Неопределено;
		КонецЕсли;
		
		Для Каждого ТекОператор Из ТекЗапрос.Операторы Цикл
			ТекОператор.КоличествоПолучаемыхЗаписей = ОграничениеВыборки;
		КонецЦикла;
		
		ТекстЗапроса = Схема.ПолучитьТекстЗапроса();
		
	КонецЕсли;
	
	СоответствиеВыражений = Новый Соответствие();
	
	Для Каждого ТекВыражение Из ПроизвольныеВыражения Цикл
		СоответствиеВыражений.Вставить(ТекВыражение.Имя, ТекВыражение.Код);
	КонецЦикла;
	
	Запрос = Новый Запрос(ТекстЗапроса);
	
	Для Каждого ТекПараметр Из Запрос_Параметры Цикл
		
		Если ВРег(ТекПараметр.Параметр_СпособЗаполнения) = ВРег("Значение")
		 ИЛИ ВРег(ТекПараметр.Параметр_СпособЗаполнения) = ВРег("Список") Тогда
			Запрос.УстановитьПараметр(ТекПараметр.Параметр_Имя, ТекПараметр.Параметр_Значение);
		ИначеЕсли ВРег(ТекПараметр.Параметр_СпособЗаполнения) = ВРег("Выражение") Тогда
			
			Результат = Неопределено;
			
			КодВыражения = СоответствиеВыражений[СокрЛП(ТекПараметр.Параметр_Значение)];
			
			РезультатВычисленияВыражения = ВычислитьВыражение(КодВыражения, Запрос_Параметры, Параметры);
			
			Запрос.УстановитьПараметр(ТекПараметр.Параметр_Имя, РезультатВычисленияВыражения);
		КонецЕсли;
	КонецЦикла;
	
	Попытка
		Результат = Запрос.Выполнить();
	Исключение
		ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
		Возврат Неопределено;
	КонецПопытки;
	
	Если ВозвращатьТаблицуЗначений Тогда
		Возврат Результат.Выгрузить();
	КонецЕсли;
	
	Возврат Результат;
	
КонецФункции // ВыполнитьЗапрос()

// Функция - Вычислить выражение
//
// Параметры:
//  КодВыражения					 - Строка			 - Программный код выражения для вычисления
//  Запрос_Параметры				 - ТаблицаЗначений	 - Параметры запроса
//  	Параметр_Имя					 - Строка		 - Имя параметра
//  	Параметр_Тип					 - Строка		 - Тип значения параметра
//  	Параметр_СпособЗаполнения		 - Строка		 - "Значение" - заполняется по значению параметра
//														   "Список" - заполняется из списка значений
//														   "Выражение" - заполняется результатом вычисления выражения
//  	Параметр_Значение				 - Произвольный	 - Значение параметра (для выражений указывается имя выражения
//														   в таблице ПроизвольныеВыражения)
//  Параметры						 - Структура		 - Дополнительные параметры, которые могут использоваться в выражениях
// 
// Возвращаемое значение:
//   - 
//
Функция ВычислитьВыражение(КодВыражения, Запрос_Параметры, Параметры)
	
	Результат = Неопределено;
	
	Если НЕ КодВыражения = Неопределено Тогда
	
		Попытка
			Выполнить(КодВыражения);
		Исключение
			//@skip-warning
			ТекстОшибки = ПодробноеПредставлениеОшибки(ИнформацияОбОшибке());
			Возврат Неопределено;
		КонецПопытки;
	Иначе
		ТекстОшибки = "Не указан текст выражения для вычисления!";
		Возврат Неопределено;
	КонецЕсли;
			
	Возврат Результат;
	
КонецФункции // ВычислитьВыражение()

#КонецОбласти
