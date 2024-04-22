create database triggerVolei

go

use triggerVolei

create table times (
	cod int not null,
	nome varchar(100) not null,
	primary key (cod)
)

go

create table jogo (
	cod			int		not null,
	codTimeA	int		not null references times (cod),
	codTimeB	int		not null references times (cod),
	setTimeA	int		not null,
	setTimeB	int		not null
	primary key (cod)
)

go

--Drop trigger t_jogo
create trigger t_jogo on jogo
after insert
as 
begin

		declare @setTimeA int,
				@setTimeB int,
				@sets int

		set @setTimeA = (select setTimeA from inserted)

		set @setTimeB  = (select setTimeB from inserted)

		set @sets = (select setTimeA from inserted) + (select setTimeB from inserted)


		if((@sets <= 5) and (@setTimeA = 3 or @setTimeB = 3))
		begin
			print 'Os valores estao correto'
		end
		else
		begin
			print 'Os valores sao invalidos'
			rollback transaction 
		end
end

-- drop function fn_tabelaVolei
create function fn_tabelaVolei()
returns @tabela table (
	nome	varchar(100),
	totalPontos int,
	totalSetGanhos int,
	totalSetPerdidos int,
	setAverage int
)
begin
		
		declare @codTime int,
				@totalPontos int,
				@aux int,
				@setGanho int,
				@setPerdido int,
				@setAvg int,
				@nome varchar(100)

				set @codTime = 1

		while(@codTime <= 4)
		begin
				
				set @totalPontos = 0
				set @setGanho = 0
				set @setPerdido = 0
				set @setAvg = 0
				set @aux = 0
				set @nome = null


				set @nome = (select nome from times where cod = @codTime)

				-- conferindo quando é time A

				set @aux =  (select count(cod) from jogo where codTimeA = @codTime and setTimeB = 2)

				if(@aux is not null)
				begin
					set @totalPontos = @totalPontos + (@aux * 2)
				end

				set @aux =  (select count(cod) from jogo where codTimeA = @codTime and setTimeB = 2)

				if(@aux is not null)
				begin
					set @totalPontos = @totalPontos + (@aux)
				end
		

				set @aux =  (select count(cod) from jogo where codTimeA = @codTime and setTimeB != 2 and setTimeA = 3)

				if(@aux is not null)
				begin
					set @totalPontos = @totalPontos + (@aux * 3)
				end

				--Verificando quando time b

				set @aux = (Select COUNT(cod) from jogo where codTimeB = @codTime and setTimeA = 2)
				if(@aux is not null) Begin
					set @totalPontos = @totalPontos + (@aux * 2)
				End

				set @aux = (Select COUNT(cod) from jogo where codTimeB = @codTime and setTimeA != 2 and setTimeB = 3)
				if(@aux is not null) Begin
					set @totalPontos = @totalPontos + (@aux * 3)
				End

				set @aux = (Select COUNT(cod) from jogo where codTimeB = @codTime and setTimeB = 2)
				if(@aux is not null) Begin
					set @totalPontos = @totalPontos + (@aux)
				End

				--Sets se for a

				If((Select sum(setTimeA) from jogo where codTimeA = @codTime) is not null) begin
					set @setGanho = (Select sum(setTimeA) from jogo where codTimeA = @codTime)
				end

				If((Select sum(setTimeB) from jogo where codTimeA = @codTime) is not null) begin
					set @setPerdido = (Select sum(setTimeB) from jogo where codTimeA = @codTime)
				end

				-- Se o time for o B

				if((Select sum(setTimeB) from jogo where codTimeB = @codTime) is not null) begin
					set @setGanho = @setGanho + (Select sum(setTimeB) from jogo where codTimeB = @codTime)
				end
				if((Select sum(setTimeA) from jogo where codTimeB = @codTime) is not null) begin
					set @setPerdido = @setPerdido + (Select sum(setTimeA) from jogo where codTimeB = @codTime)
				end

				set @setAvg = @setGanho - @setPerdido

				insert into @tabela (nome, totalPontos, totalSetGanhos, totalSetPerdidos, setAverage)
							select @nome, @totalPontos, @setGanho, @setPerdido, @setAvg
							

				set @codTime = @codTime + 1

		end

		return
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

INSERT INTO times (cod, nome) VALUES
(1, 'Time A'),
(2, 'Time B'),
(3, 'Time C'),
(4, 'Time D');
Go
Insert Into jogo values
(1,1,2,3,2)

Insert Into jogo values
(2,1,2,4,0)


select * from jogo where codTimeA = 2 and setTimeB = 2
select * from jogo where codTimeB = 2 and setTimeA = 2

select * from jogo where codTimeA = 2 and setTimeB != 2
select * from jogo where codTimeB = 2 and setTimeA != 2

select * from jogo where codTimeA = 2 and setTimeA = 2
select * from jogo where codTimeA = 2 and setTimeB = 2

-- delete jogo

 -- enable trigger t_jogo on jogo
 -- disable trigger t_jogo on jogo


INSERT INTO jogo 
VALUES
    (1, 1, 2, 3, 2), -- Time 1 vs Time 2 - Time 1 venceu por 3 sets a 2
    (2, 1, 3, 3, 1), -- Time 1 vs Time 3 - Time 1 venceu por 3 sets a 1
    (3, 1, 4, 3, 0), -- Time 1 vs Time 4 - Time 1 venceu por 3 sets a 0
    (4, 2, 3, 2, 3), -- Time 2 vs Time 3 - Time 3 venceu por 3 sets a 2
    (5, 2, 4, 1, 3), -- Time 2 vs Time 4 - Time 4 venceu por 3 sets a 1
    (6, 3, 4, 0, 3); -- Time 3 vs Time 4 - Time 4 venceu por 3 sets a 0


select count(cod) from jogo where codTimeA = 1 and setTimeB != 2


select * from fn_tabelaVolei()