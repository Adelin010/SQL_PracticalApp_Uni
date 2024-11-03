use Labor;

declare @i int, @que varchar(1024)
set @i = 1
while @i < 5 
begin 
    set @que = 'drop database Labor_' + cast(@i as varchar(2)) + '_snap'
    print @que
    exec(@que)
    set @i = @i + 1
end 
go



select * from Versions

select * from Current_Version

insert into Current_Version values(0)

use master
restore database Labor from DATABASE_SNAPSHOT = 'Labor_Snapshot_20241027'


create database Labor_Snapshot_20241028


use Labor

drop table SnapShotsDB, VersionDB

--Remake the Labor3

create table Versions (
    version_id int identity(1, 1) not null,
    proc_name varchar(100) not null,
    args varchar(255),
    constraint Versions_PK primary key(version_id)
)

create table Current_Version(
    version_id int not null
)

insert into Current_Version values (0)
--Saving a copy in case we make mistakes
create database Labor_Snapshot_20241028
on(name = Labor, filename ='/var/opt/mssql/data/Labor_Snapshot_20241028')
as snapshot of Labor

use Labor

drop table Versions

drop database Labor_Snapshot_20241026

go


--Start the procedure making:

--procedure for creating a Version and adding it 
-- ! When adding a new Version always update the Current_Version table
-- if @flag = 0 then break the procedure

create procedure Add_Version(@proc_name varchar(255), @args varchar(255), @flag bit = 1)as begin  

    declare @que varchar(1024)

    if @flag = 0
    begin 
        return;
        print 'Procedure called from the history backtracking'
    end

    if @args like ''
    begin 

        set @que = 'insert into Versions(proc_name) values (''' + @proc_name + ''')' 
    end 
    else
    begin  
        set @que = 'insert into Versions(proc_name, args) values (''' + @proc_name + ''', ''''' + @args + ''''')'
    end  
    print @que
    exec(@que)
    -- Update the Current_Version 
    declare @v_id int
    set @v_id = (select max(version_id) from Versions )
    set @que = 'update Current_Version set version_id = ' + cast(@v_id as varchar(100))
    print @que
    exec(@que)
    

end 
go 

--1. Procedure for creating a Table

create procedure Create_Table (@tab_name varchar(255), @flag bit = 1) as begin 

    declare @que varchar(1024)
    set @que =  'if OBJECT_ID(''dbo.' + @tab_name + ''', N''U'') is null ' +' begin create table ' + QUOTENAME(@tab_name) + '( id int identity(1, 1) not null, ' + 'attr' + 
    ' varchar(255), country_code varchar(10) not null, constraint '+ @tab_name + '_PK' + ' primary key(id) ) end'
    print @que
    exec(@que)

    declare @args varchar(255)
    set @args = '''' + @tab_name + ''''
    exec Add_Version 'Create_Table', @args, @flag
end 
go 


create procedure Undo_Create_Table(@tab_name varchar(255), @flag bit = 1)as begin 

    declare @que varchar(1024)
    set @que = 'drop table if exists ' + QUOTENAME(@tab_name)
    print @que 
    exec(@que)

    declare @args varchar(255)
    set @args ='''' + @tab_name + ''''
    exec Add_Version 'Undo_Create_Table', @args, @flag

end 
go 

exec Create_Table 'State'

exec Create_Table 'Dime'

drop table [State]


select * from Versions

select * from Current_Version

truncate table Versions

exec Undo_Create_Table 'State'

exec Undo_Create_Table 'Dime'

drop procedure Create_Table, Undo_Create_Table, Add_Version

use master

restore database Labor 
from DATABASE_SNAPSHOT = 'Labor_Snapshot_20241026'

select * from Dimension
go
--Procedure for adding a default constraint 
--Name of the constraint : default_@field
create procedure Add_Default_Constraint (@tab_name varchar(255), @const_name varchar(255) ,@field varchar(255), @value varchar(255), @flag bit = 1)as begin 

    declare @que varchar(1024)
    set @que = 'if OBJECT_ID(''dbo.' + @tab_name + ''', N''U'') is not null ' + ' begin alter table ' + @tab_name + ' add constraint ' + @const_name + ' default ''' + @value + ''' for ' + @field + ' end'
    print @que
    exec(@que)

    declare @args varchar(255)
    set @args = '''' + @tab_name + '''''#''''' + @const_name + '''''#''''' + @field + '''''#''''' + @value + ''''
    exec Add_Version 'Add_Default_Constraint', @args, @flag

end 
go 

create procedure Undo_Add_Default_Constraint (@tab_name varchar(255), @const_name varchar(255),@field varchar(255) ,@value varchar(255), @flag bit = 1)as begin 

    declare @que varchar(1024)
    set @que = 'if OBJECT_ID(''dbo.' + @tab_name + ''', N''U'') is not null ' + ' begin alter table ' + @tab_name + ' drop constraint ' + @const_name + ' end'
    exec(@que)

    declare @args varchar(255)
    set @args = '''' + @tab_name + '''''#''''' + @const_name + '''''#''''' + @field + '''''#''''' + @value + ''''
    exec Add_Version 'Undo_Add_Default_Constraint', @args, @flag
end 
go 

exec Add_Default_Constraint 'State', 'default_const', 'attr', 'def' 

exec sp_help State

truncate table Versions

exec Undo_Add_Default_Constraint 'State', 'default_const' ,'attr', 'def'

drop procedure Add_Default_Constraint, Undo_Add_Default_Constraint
go


--Procedure for the foreign key constraint 
-- name of the constraint: @tableName_@field_FK
create procedure Add_FK(@tab_name varchar(255), @field varchar(255), @ref_table varchar(255), @ref_field varchar(255), @flag bit = 1) as begin 

    declare @que varchar(1024)
    set @que = 'if OBJECT_ID(''dbo.' + @tab_name + ''', N''U'') is not null ' + ' begin alter table ' + @tab_name + ' add constraint ' + @tab_name + '_'+ @field + '_FK foreign key(' + @field + ') references '
                + @ref_table + '(' + @ref_field + ') end'
    print @que
    exec(@que)


    
    declare @args varchar(255)
    set @args = '''' +  @tab_name + '''''#''''' + @field + '''''#''''' + @ref_table + '''''#''''' + @ref_field + ''''
    exec Add_Version 'Add_FK', @args, @flag

end 
go 

create procedure Undo_Add_FK(@tab_name varchar(255), @field varchar(255), @ref_table varchar(255), @ref_field varchar(255), @flag bit = 1) as begin 

    declare @que varchar(1024)
    set @que =  'if OBJECT_ID(''dbo.' + @tab_name + ''', N''U'') is not null ' + ' begin alter table ' + @tab_name + ' drop constraint ' + @tab_name + '_' + @field + '_FK end'
    print @que
    exec(@que)



    declare @args varchar(255)
    set @args = '''' +  @tab_name + '''''#''''' + @field + '''''#''''' + @ref_table + '''''#''''' + @ref_field + ''''
    exec Add_Version 'Undo_Add_FK', @args, @flag

end 
go 


exec Add_FK 'State', 'country_code', 'Country', 'code'

exec sp_help Dimension

exec Undo_Add_FK 'State', 'country_code', 'Country', 'code'

drop procedure Add_FK, Undo_Add_FK

go

-- procedure for changing the type of a column
create procedure Change_Column(@tab_name varchar(255), @col_name varchar(255), @type varchar(255), @old_type varchar(255), @flag bit = 1) as begin 

    declare @que varchar(1024)
    set @que = 'if OBJECT_ID(''dbo.' + @tab_name + ''', N''U'') is not null ' + ' begin alter table ' + @tab_name + ' alter column ' + @col_name + ' ' + @type  + ' end'
    print @que 
    exec(@que)

    declare @args varchar(255)
    set @args = ''''  + @tab_name + '''''#''''' + @col_name + '''''#''''' + @type + '''''#''''' + @old_type + ''''
    exec Add_Version 'Change_Column', @args, @flag

end 
go 

create procedure Undo_Change_Column(@tab_name varchar(255), @col_name varchar(255), @type varchar(255),@old_type varchar(255) ,@flag bit = 1) as begin 

    declare @que varchar(1024)
    set @que = 'if OBJECT_ID(''dbo.' + @tab_name + ''', N''U'') is not null ' + ' begin alter table ' + @tab_name + ' alter column ' + @col_name + ' ' + @type + ' end'
    print @que 
    exec(@que)

    declare @args varchar(255)
    set @args = ''''  + @tab_name + '''''#''''' + @col_name + '''''#''''' + @type + '''''#''''' + @old_type  + ''''
    exec Add_Version 'Undo_Change_Column', @args, @flag

end 
go 

exec Change_Column 'State', 'attr', 'text', 'varchar(255)'

exec Undo_Change_Column 'State', 'attr', 'varchar(255)', 'text'

exec sp_help State


select * from Versions

drop procedure Change_Column, Undo_Change_Column

go 

--Procedures for adding a column and remove it
create procedure Add_Column(@tab_name varchar(255), @col_name varchar(255), @col_type varchar(255), @flag bit = 1) as begin 

    declare @que varchar(255)
    set @que = 'if OBJECT_ID(''dbo.' + @tab_name + ''', N''U'') is not null ' + ' begin alter table ' + @tab_name + ' add ' + @col_name + ' ' + @col_type + ' end'
    print @que 
    exec(@que)
    

    declare @args varchar(255)
    set @args = '''' + @tab_name + '''''#''''' + @col_name + '''''#''''' + @col_type + ''''
    exec Add_Version 'Add_Column', @args, @flag
end 
go 

create procedure Undo_Add_Column(@tab_name varchar(255), @col_name varchar(255), @col_type varchar(255), @flag bit = 1) as begin 

    declare @que varchar(255)
    set @que = 'if OBJECT_ID(''dbo.' + @tab_name + ''', N''U'') is not null ' + ' begin alter table ' + @tab_name + ' drop column ' + @col_name + ' end'
    print @que 
    exec(@que)
    

    declare @args varchar(255)
    set @args = '''' + @tab_name + '''''#''''' + @col_name + '''''#''''' + @col_type + ''''
    exec Add_Version 'Undo_Add_Column', @args, @flag
end 
go 


exec Add_Column 'State', 'Added3', 'text'

select * from Dimension

select * from Versions

TRUNCATE table Versions

exec Undo_Add_Column 'State', 'Added3', 'text'


drop procedure Add_Column, Undo_Add_Column

go 
--Prcedure to move in history 


create procedure history (@version int ) as begin 
    declare @maxim_version int, @current int, @que varchar(1024) 
    set @maxim_version = (select max(version_id) from Versions)
    set @current = (select version_id from Current_Version)

    declare @proc_name varchar(255), @args varchar(255), @proc nvarchar(1024), @restore_query varchar(1024)

    if(@version <= @maxim_version and @version != @current)
    begin 

        if(@version < @current)
        begin 
            --Starting point current | each step --
            while (@version < @current)
            begin  

                --Select the procedure you need and the arguments from the Version table based on the current 
                
                set @proc = 'select @proc_name = v.proc_name from Versions v where v.version_id =  @current'
                execute sp_executesql @proc, N'@proc_name varchar(255) output, @current int', @proc_name=@proc_name output, @current = @current

                set @proc = 'select @args = v.args from Versions v where v.version_id = @current '
                execute sp_executesql @proc, N'@args varchar(255) output, @current int', @args=@args output, @current=@current 
                print @proc_name +  ' | ' + @args  

                -- Treat the Change_Column Type case when in history returning 
                if(@proc_name like '%Change_Column')
                begin 
                    declare @arg1 varchar(255), @arg2 varchar(255), @arg3 varchar(255), @arg4 varchar(255)
                    set @arg1 = (select value from string_split(@args, '#', 1) where ordinal = 1)
                    set @arg2 = (select value from string_split(@args, '#', 1) where ordinal = 2)
                    set @arg3 = (select value from string_split(@args, '#', 1) where ordinal = 3)
                    set @arg4 = (select value from string_split(@args, '#', 1) where ordinal = 4)
                    set @args = @arg1 + '#' + @arg2 + '#' + @arg4 + '#' + @arg3 
                    print @args
 
                end 

                if(@proc_name like 'Undo%')
                begin 
                    set @proc_name = SUBSTRING(@proc_name, 6, len(@proc_name) - 6 + 1)
                    print @proc_name 
                end 
                else 
                begin 
                    set @proc_name = 'Undo_' + @proc_name 
                    print @proc_name
                end 

                
                set @restore_query = @proc_name + ' ' + REPLACE(@args, '#', ',') + ', 0'
                exec(@restore_query)
                print @restore_query



                --get the version where you have to go
                set @current = @current - 1 
            end 
        end
        else
        begin 
            while(@current < @version)
            begin 
                --get the version where you have to go
                set @current = @current + 1


                set @proc = 'select @proc_name = v.proc_name from Versions v where v.version_id =  @current'
                execute sp_executesql @proc, N'@proc_name varchar(255) output, @current int', @proc_name=@proc_name output, @current = @current

                set @proc = 'select @args = v.args from Versions v where v.version_id = @current '
                execute sp_executesql @proc, N'@args varchar(255) output, @current int', @args=@args output, @current=@current 
                print @proc_name +  ' | ' + @args  

                -- if(@proc_name like 'Undo%')
                -- begin 
                --     set @proc_name = SUBSTRING(@proc_name, 6, len(@proc_name) - 6 + 1)
                --     print @proc_name 
                -- end 
                -- else 
                -- begin 
                --     set @proc_name = 'Undo_' + @proc_name 
                --     print @proc_name
                -- end 

                set @restore_query = @proc_name + ' ' + REPLACE(@args, '#', ',') + ', 0'
                exec(@restore_query)
                print @restore_query

                
            end 
                   
        end

        set @que = 'update Current_Version set version_id = ' + cast(@version as varchar(100))
        print @que
        exec(@que)

    end 

end 
go 


exec history 6

select * from Versions

select * from Current_Version




exec sp_help State

truncate table Versions



use Labor

drop procedure history

select * from State


