trigger UserTrigger on User (after insert, after update) {

    if(Trigger.isAfter && Trigger.isInsert){
        List<User> userNewList=new  List<User>();
        for(User u:(List<User>)Trigger.New){
            if(u.isActive==true && u.userType == 'Standard' && u.AccountId == null){
                userNewList.add(u);
            }        
        }
        if(userNewList != null && userNewList.size()>0){
            AP232_SysAdminCreationTriggerHandler.afterUserInserted(userNewList);
        }
    }
    
    if(Trigger.isAfter && Trigger.isUpdate){
        
        Map<Id,User> userOldMap=new  Map<Id,User>();
        List<User> userNewList=new  List<User>();
        for(User u:(List<User>)Trigger.New){
            if(u.isActive == true && u.userType == 'Standard' && u.AccountId == null){
                userNewList.add(u);
                userOldMap.put(u.Id, (User)Trigger.OldMap.get(u.Id));
            }
        }
        if(userNewList != null && userNewList.size()>0){
            AP232_SysAdminCreationTriggerHandler.afterUserUpdate(userOldMap, userNewList);
        }
    }
}