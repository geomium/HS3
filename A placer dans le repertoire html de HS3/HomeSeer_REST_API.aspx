<%@ Page Language="C#" %>

<script runat="server">
    // ====================================================================================================
    // Author: Stephen Shamakian
    // URL: http://redtechie.com
    // Version: 1.1.0
    // Built for HomeSeer Version: v3+
    //
    // Usage: http://(HS3 URL)/HomeSeer_REST_API.aspx?function=(FUNC NAME)[&param1=(PARAM 1 VALUE)&param2=(PARAM 2 VALUE)]
    // ====================================================================================================


    private Scheduler.hsapplication hs;
    
    // Loads on page render
    void Page_Load(object Sender, EventArgs E) 
    {
        //  Get our HS object from the HomeSeer WebServer
        hs = (Scheduler.hsapplication)Context.Items["Content"];
        
        // Get and clean our function name from the URI string
        string q_function = Server.UrlDecode(Request.QueryString["function"]);
        if (q_function == "" || q_function == null) { q_function = "blank"; }

        // Get and clean our Parameter 1 from the URI string
        string q_functionParam1 = Server.UrlDecode(Request.QueryString["param1"]);
        if (q_functionParam1 == "" || q_functionParam1 == null) { q_functionParam1 = ""; }

        // Get and clean our Parameter 2 from the URI string
        string q_functionParam2 = Server.UrlDecode(Request.QueryString["param2"]);
        if (q_functionParam2 == "" || q_functionParam2 == null) { q_functionParam2 = ""; }

        // Get and clean our Parameter 3 from the URI string
        string q_functionParam3 = Server.UrlDecode(Request.QueryString["param3"]);
        if (q_functionParam3 == "" || q_functionParam3 == null) { q_functionParam3 = ""; }

        HandleRESTAction(q_function, q_functionParam1, q_functionParam2, q_functionParam3);
    }


    void HandleRESTAction(string q_function, string q_functionParam1, string q_functionParam2, string q_functionParam3)
    {   
        q_function = q_function.ToLower();
        q_functionParam1 = q_functionParam1.ToLower();
        q_functionParam2 = q_functionParam2.ToLower();
        q_functionParam3 = q_functionParam3.ToLower();

        switch (q_function)
        {
            case "speak":
                ICanTalk(q_functionParam1);
                break;
            case "listevents":
                Response.Write(ListEvents(q_functionParam1));
                break;
            case "execevent":
                Response.Write(ExecEvent(q_functionParam1));
                break;
            case "execeventbyid":
                Response.Write(ExecEventByID(Convert.ToInt32(q_functionParam1))); // New in v1.1
                break;
            case "listfirstlocations":
                Response.Write(GetAllFirstLocationsString());
                break;
            case "listsecondlocations":
                Response.Write(GetAllSecondLocationsString());
                break;
            case "listdevices":
                Response.Write(ListDevices(q_functionParam1, q_functionParam2));
                break;
            case "getdevicesforlocation":
                Response.Write(GetDevicesForLocation(q_functionParam1, q_functionParam2));
                break;
            case "getdeviceinfo":
                Response.Write(GetDeviceInfo(q_functionParam1));
                break;
            case "getdeviceinfobyid":
                Response.Write(GetDeviceInfoByID(Convert.ToInt32(q_functionParam1))); // New in v1.1
                break;
            case "devicestatusbyname":
                Response.Write(DeviceStatusByName(q_functionParam1, q_functionParam2));
                break;
            case "devicestatusbyid":
                Response.Write(DeviceStatusByID(Convert.ToInt32(q_functionParam1), q_functionParam2));
                break;
            case "getdevicestatusvaluebyname":
                Response.Write(GetDeviceStatusValueByName(q_functionParam1, q_functionParam2)); // New in v1.1
                break;
            case "getdevicestatusvaluebyid":
                Response.Write(GetDeviceStatusValueByID(Convert.ToInt32(q_functionParam1), q_functionParam2)); // New in v1.1
                break;
            case "setdevicebyname":
                Response.Write(SetDeviceByName(q_functionParam1, q_functionParam2));
                break;
            case "setdevicebyid":
                Response.Write(SetDeviceByID(Convert.ToInt32(q_functionParam1), q_functionParam2));
                break;
            case "runscript":
                ICanScript(q_functionParam1);
                break;
            case "runscriptfunc":
                ICanScriptFunc(q_functionParam1, q_functionParam2, q_functionParam3);
                break;
            default:
                Response.Write("Unknown function: '" + q_function + "'. This action has been logged.");
                hs.WriteLog("RESTful-API", "Unknown function '" + q_function + "' invoked from IP " + Request.ServerVariables["REMOTE_ADDR"]);
                break;
        }
    }
    
    // Execute Script
    void ICanScript(string scriptName)

    {   
        hs.RunScript(scriptName,true,true);
        Response.Write("SCRIPT OK");
           
    }

// Execute ScriptFunc
    void ICanScriptFunc(string scriptName, string scriptSub, string scriptFunc)

    {   
        hs.RunScriptFunc(scriptName,scriptSub,scriptFunc,true,true);
        Response.Write("SCRIPT FUNC OK");
               
    }





    // Talk to me
    void ICanTalk(string talkThis) 
    {
        hs.Speak(talkThis, false, "");
        Response.Write("Sent phrase to HomeSeer...");
    }
    
    
    
    // List of Events
    string ListEvents(string eventType)
    {
        string output = String.Empty;
        HomeSeerAPI.strEventGroupData[] evGrpInfo = hs.Event_Group_Info_All();

        output = "<eventList>";
        
        foreach(HomeSeerAPI.strEventGroupData evGroup in evGrpInfo)
        {
            output += "<eventGroup name=\"" + evGroup.GroupName + "\" id=\"" + evGroup.GroupID + "\">";
            
            HomeSeerAPI.strEventData[] evInfo = hs.Event_Info_Group(evGroup.GroupID);

            foreach (HomeSeerAPI.strEventData ev in evInfo)
            {
                if (eventType.ToLower() != "all")
                {
                    if (ev.Event_Type.ToLower() == eventType.ToLower())
                    {
                        output += "<event name=\"" + ev.Event_Name + "\" id=\"" + ev.Event_Ref.ToString() + "\" type=\"" + ev.Event_Type + "\" enabled=\"" + ev.Flag_Enabled.ToString() + "\" includeInPowerfail=\"" + ev.Flag_Include_in_Powerfail.ToString() + "\" priorityEvent=\"" + ev.Flag_Priority_Event.ToString() + "\" security=\"" + ev.Flag_Security.ToString() + "\" />";
                    }
                }
                else
                {
                    output += "<event name=\"" + ev.Event_Name + "\" id=\"" + ev.Event_Ref.ToString() + "\" type=\"" + ev.Event_Type + "\" enabled=\"" + ev.Flag_Enabled.ToString() + "\" includeInPowerfail=\"" + ev.Flag_Include_in_Powerfail.ToString() + "\" priorityEvent=\"" + ev.Flag_Priority_Event.ToString() + "\" security=\"" + ev.Flag_Security.ToString() + "\" />";
                }
            }
            
            output += "</eventGroup>";
            
        }

        output += "</eventList>";
        
        return output;
    }
    
    
    
    // Execute Event
    string ExecEvent(string eventName)
    {
        int returnCode = hs.TriggerEvent(eventName);

        if (returnCode == 0)
        {
            //Error
            return "False";
        }
        else
        {
            //Success
            return "True";
        }
    }



    // Execute Event by ID
    // New in v1.1
    string ExecEventByID(int eventRef)
    {
        string eventName = hs.EventName(eventRef);
        int returnCode = hs.TriggerEvent(eventName);

        if (returnCode == 0)
        {
            //Error
            return "False";
        }
        else
        {
            //Success
            return "True";
        }
    }



    // Get All First Locations
    // Returns: string
    string GetAllFirstLocationsString()
    {
        Scheduler.Classes.clsDeviceEnumeration EN = (Scheduler.Classes.clsDeviceEnumeration)hs.GetDeviceEnumerator();
        string output = String.Empty;
        Scheduler.Classes.DeviceClass dv;

        output = "<firstLocationList>";
        
        while (EN.Finished == false)
        {
            dv = EN.GetNext();
            if (dv == null)
            {
                continue;
            }

            //Enforces Unique values (No duplicates)
            if (!output.Contains(dv.get_Location(hs)))
            {
                output += "<location name=\"" + dv.get_Location(hs) + "\" />";
            }
        }

        output += "</firstLocationList>";
        
        return output;
    }



    // Get All Second Locations
    // Returns: string
    string GetAllSecondLocationsString()
    {
        Scheduler.Classes.clsDeviceEnumeration EN = (Scheduler.Classes.clsDeviceEnumeration)hs.GetDeviceEnumerator();
        string output = String.Empty;
        Scheduler.Classes.DeviceClass dv;

        output = "<secondLocationList>";
        
        while (EN.Finished == false)
        {
            dv = EN.GetNext();
            if (dv == null)
            {
                continue;
            }

            //Enforces Unique values (No duplicates)
            if (!output.Contains(dv.get_Location2(hs)))
            {
                output += "<location name=\"" + dv.get_Location2(hs) + "\" />";
            }
        }

        output += "</secondLocationList>";
        
        return output;
    }
    
    
    
    // Get All First Locations
    // Returns: List
    System.Collections.Generic.List<string> GetAllFirstLocations()
    {
        Scheduler.Classes.clsDeviceEnumeration EN = (Scheduler.Classes.clsDeviceEnumeration)hs.GetDeviceEnumerator();
        System.Collections.Generic.List<string> output = new System.Collections.Generic.List<string>();
        Scheduler.Classes.DeviceClass dv;

            while (EN.Finished == false)
            {
                dv = EN.GetNext();
                if (dv == null)
                {
                    continue;
                }

                //Enforces Unique values (No duplicates)
                if (!output.Contains(dv.get_Location(hs)))
                {
                    output.Add(dv.get_Location(hs));
                }
            }

        return output;
    }



    // Get All Second Locations
    // Returns: List
    System.Collections.Generic.List<string> GetAllSecondLocations()
    {
        Scheduler.Classes.clsDeviceEnumeration EN = (Scheduler.Classes.clsDeviceEnumeration)hs.GetDeviceEnumerator();
        System.Collections.Generic.List<string> output = new System.Collections.Generic.List<string>();
        Scheduler.Classes.DeviceClass dv;
        
            //Compile a list from all devices
            while (EN.Finished == false)
            {
                dv = EN.GetNext();
                if (dv == null)
                {
                    continue;
                }

                //Enforces Unique values (No duplicates)
                if (!output.Contains(dv.get_Location2(hs)))
                {
                    output.Add(dv.get_Location2(hs));
                }
            }

        return output;
    }
    
    
    //  List of Devices
    //----------
    // deviceType Values
    // - all = display all types of devices
    // - (type) - display only that type of device
    //----------
    // orderLogic Values
    // - (string)0 = Display all devices regardless of locations
    // - (string)1 = Display devices by Location1 then Location2
    // - (string)2 = Display devices by Location2 then Location1
    //----------
    string ListDevices(string deviceType, string orderLogic) 
    {
        string output = String.Empty;
        Scheduler.Classes.DeviceClass dv;

        // Check for multiple device types
        string[] arraySplit = deviceType.Split('*');
        System.Collections.Generic.List<string> deviceTypes = new System.Collections.Generic.List<string>(arraySplit);

        output = "<deviceList>";
        
        if (orderLogic == "1")
        {
            //Display by Location1 then Location2
            foreach (string loc1Name in GetAllFirstLocations())
            {
                if (loc1Name != "")
                {
                    //Looping through each Location1...
                    output += "<devicePrimaryLocation name=\"" + loc1Name + "\">";

                    //Loop through devices that have this location set and get their Location2 names
                    Scheduler.Classes.clsDeviceEnumeration EN = (Scheduler.Classes.clsDeviceEnumeration)hs.GetDeviceEnumerator();
                    System.Collections.Generic.List<string> location2Names = new System.Collections.Generic.List<string>();

                    while (EN.Finished == false)
                    {
                        dv = EN.GetNext();
                        if (dv == null)
                        {
                            continue;
                        }

                        if (dv.get_Location(hs) == loc1Name)
                        {
                            if (deviceType.ToLower() != "all")
                            {
                                if (deviceTypes.Contains(dv.get_Device_Type_String(hs).ToLower()))
                                {
                                    //No duplicates
                                    if (!location2Names.Contains(dv.get_Location2(hs)))
                                    {
                                        location2Names.Add(dv.get_Location2(hs));
                                    }

                                    //If no location2 display my device
                                    if (dv.get_Location2(hs) == "")
                                    {
                                        output += "<device name=\"" + dv.get_Name(hs) + "\" id=\"" + dv.get_Ref(hs).ToString() + "\" type=\"" + dv.get_Device_Type_String(hs) + "\" value=\"" + dv.get_devValue(hs).ToString() + "\" address=\"" + dv.get_Address(hs) + "\" code=\"" + dv.get_Code(hs) + "\" canDim=\"" + dv.get_Can_Dim(hs).ToString() + "\" lastChange=\"" + dv.get_Last_Change(hs).ToString() + "\" firstLocation=\"" + dv.get_Location(hs) + "\" secondLocation=\"" + dv.get_Location2(hs) + "\" />";
                                    }
                                }
                            }
                            else
                            {
                                //No duplicates
                                if (!location2Names.Contains(dv.get_Location2(hs)))
                                {
                                    location2Names.Add(dv.get_Location2(hs));
                                }

                                //If no location2 display my device
                                if (dv.get_Location2(hs) == "")
                                {
                                    output += "<device name=\"" + dv.get_Name(hs) + "\" id=\"" + dv.get_Ref(hs).ToString() + "\" type=\"" + dv.get_Device_Type_String(hs) + "\" value=\"" + dv.get_devValue(hs).ToString() + "\" address=\"" + dv.get_Address(hs) + "\" code=\"" + dv.get_Code(hs) + "\" canDim=\"" + dv.get_Can_Dim(hs).ToString() + "\" lastChange=\"" + dv.get_Last_Change(hs).ToString() + "\" firstLocation=\"" + dv.get_Location(hs) + "\" secondLocation=\"" + dv.get_Location2(hs) + "\" />";
                                }
                            }
                        }
                    }

                    if (location2Names != null)
                    {
                        //I now have a list Location 2 names inside of Location 1. Lets loop through them
                        foreach (string loc2Name in location2Names)
                        {
                            if (loc2Name != "")
                            {
                                output += "<deviceSecondaryLocation name=\"" + loc2Name + "\">";

                                Scheduler.Classes.clsDeviceEnumeration EN2 = (Scheduler.Classes.clsDeviceEnumeration)hs.GetDeviceEnumerator();
                                
                                while (EN2.Finished == false)
                                {
                                    dv = EN2.GetNext();
                                    if (dv == null)
                                    {
                                        continue;
                                    }

                                    if (dv.get_Location2(hs) == loc2Name && dv.get_Location(hs) == loc1Name)
                                    {
                                        if (deviceType.ToLower() != "all")
                                        {
                                            if (deviceTypes.Contains(dv.get_Device_Type_String(hs).ToLower()))
                                            {
                                                output += "<device name=\"" + dv.get_Name(hs) + "\" id=\"" + dv.get_Ref(hs).ToString() + "\" type=\"" + dv.get_Device_Type_String(hs) + "\" value=\"" + dv.get_devValue(hs).ToString() + "\" address=\"" + dv.get_Address(hs) + "\" code=\"" + dv.get_Code(hs) + "\" canDim=\"" + dv.get_Can_Dim(hs).ToString() + "\" lastChange=\"" + dv.get_Last_Change(hs).ToString() + "\" firstLocation=\"" + dv.get_Location(hs) + "\" secondLocation=\"" + dv.get_Location2(hs) + "\" />";
                                            }
                                        }
                                        else
                                        {
                                            output += "<device name=\"" + dv.get_Name(hs) + "\" id=\"" + dv.get_Ref(hs).ToString() + "\" type=\"" + dv.get_Device_Type_String(hs) + "\" value=\"" + dv.get_devValue(hs).ToString() + "\" address=\"" + dv.get_Address(hs) + "\" code=\"" + dv.get_Code(hs) + "\" canDim=\"" + dv.get_Can_Dim(hs).ToString() + "\" lastChange=\"" + dv.get_Last_Change(hs).ToString() + "\" firstLocation=\"" + dv.get_Location(hs) + "\" secondLocation=\"" + dv.get_Location2(hs) + "\" />";
                                        }
                                    }
                                }

                                output += "</deviceSecondaryLocation>";
                                
                            }
                        }
                    }

                    output += "</devicePrimaryLocation>";
                    
                }
            }
        }
        else if (orderLogic == "2")
        {
            //Display by Location2 then Location1
            foreach (string loc2Name in GetAllSecondLocations())
            {
                if (loc2Name != "")
                {
                    //Looping through each Location2...
                    output += "<devicePrimaryLocation name=\"" + loc2Name + "\">";

                    //Loop through devices that have this location set and get their Location1 names
                    Scheduler.Classes.clsDeviceEnumeration EN = (Scheduler.Classes.clsDeviceEnumeration)hs.GetDeviceEnumerator();
                    System.Collections.Generic.List<string> location1Names = new System.Collections.Generic.List<string>();

                    while (EN.Finished == false)
                    {
                        dv = EN.GetNext();
                        if (dv == null)
                        {
                            continue;
                        }

                        if (dv.get_Location2(hs) == loc2Name)
                        {
                            if (deviceType.ToLower() != "all")
                            {
                                if (deviceTypes.Contains(dv.get_Device_Type_String(hs).ToLower()))
                                {
                                    //No duplicates
                                    if (!location1Names.Contains(dv.get_Location(hs)))
                                    {
                                        location1Names.Add(dv.get_Location(hs));
                                    }

                                    //If no location1 display my device
                                    if (dv.get_Location(hs) == "")
                                    {
                                        output += "<device name=\"" + dv.get_Name(hs) + "\" id=\"" + dv.get_Ref(hs).ToString() + "\" type=\"" + dv.get_Device_Type_String(hs) + "\" value=\"" + dv.get_devValue(hs).ToString() + "\" address=\"" + dv.get_Address(hs) + "\" code=\"" + dv.get_Code(hs) + "\" canDim=\"" + dv.get_Can_Dim(hs).ToString() + "\" lastChange=\"" + dv.get_Last_Change(hs).ToString() + "\" firstLocation=\"" + dv.get_Location(hs) + "\" secondLocation=\"" + dv.get_Location2(hs) + "\" />";
                                    }
                                }
                            }
                            else
                            {
                                //No duplicates
                                if (!location1Names.Contains(dv.get_Location(hs)))
                                {
                                    location1Names.Add(dv.get_Location(hs));
                                }

                                //If no location1 display my device
                                if (dv.get_Location(hs) == "")
                                {
                                    output += "<device name=\"" + dv.get_Name(hs) + "\" id=\"" + dv.get_Ref(hs).ToString() + "\" type=\"" + dv.get_Device_Type_String(hs) + "\" value=\"" + dv.get_devValue(hs).ToString() + "\" address=\"" + dv.get_Address(hs) + "\" code=\"" + dv.get_Code(hs) + "\" canDim=\"" + dv.get_Can_Dim(hs).ToString() + "\" lastChange=\"" + dv.get_Last_Change(hs).ToString() + "\" firstLocation=\"" + dv.get_Location(hs) + "\" secondLocation=\"" + dv.get_Location2(hs) + "\" />";
                                }
                            }
                        }
                    }

                    if (location1Names != null)
                    {
                        //I now have a list Location 1 names inside of Location 2. Lets loop through them
                        foreach (string loc1Name in location1Names)
                        {
                            if (loc1Name != "")
                            {
                                output += "<deviceSecondaryLocation name=\"" + loc1Name + "\">";

                                Scheduler.Classes.clsDeviceEnumeration EN1 = (Scheduler.Classes.clsDeviceEnumeration)hs.GetDeviceEnumerator();

                                while (EN1.Finished == false)
                                {
                                    dv = EN1.GetNext();
                                    if (dv == null)
                                    {
                                        continue;
                                    }

                                    if (dv.get_Location(hs) == loc1Name && dv.get_Location2(hs) == loc2Name)
                                    {
                                        if (deviceType.ToLower() != "all")
                                        {
                                            if (deviceTypes.Contains(dv.get_Device_Type_String(hs).ToLower()))
                                            {
                                                output += "<device name=\"" + dv.get_Name(hs) + "\" id=\"" + dv.get_Ref(hs).ToString() + "\" type=\"" + dv.get_Device_Type_String(hs) + "\" value=\"" + dv.get_devValue(hs).ToString() + "\" address=\"" + dv.get_Address(hs) + "\" code=\"" + dv.get_Code(hs) + "\" canDim=\"" + dv.get_Can_Dim(hs).ToString() + "\" lastChange=\"" + dv.get_Last_Change(hs).ToString() + "\" firstLocation=\"" + dv.get_Location(hs) + "\" secondLocation=\"" + dv.get_Location2(hs) + "\" />";
                                            }
                                        }
                                        else
                                        {
                                            output += "<device name=\"" + dv.get_Name(hs) + "\" id=\"" + dv.get_Ref(hs).ToString() + "\" type=\"" + dv.get_Device_Type_String(hs) + "\" value=\"" + dv.get_devValue(hs).ToString() + "\" address=\"" + dv.get_Address(hs) + "\" code=\"" + dv.get_Code(hs) + "\" canDim=\"" + dv.get_Can_Dim(hs).ToString() + "\" lastChange=\"" + dv.get_Last_Change(hs).ToString() + "\" firstLocation=\"" + dv.get_Location(hs) + "\" secondLocation=\"" + dv.get_Location2(hs) + "\" />";
                                        }
                                    }
                                }

                                output += "</deviceSecondaryLocation>";
                                
                            }
                        }
                    }

                    output += "</devicePrimaryLocation>";
                    
                }
            }
        }
        else
        {
            //Display all devices without location information
            Scheduler.Classes.clsDeviceEnumeration EN = (Scheduler.Classes.clsDeviceEnumeration)hs.GetDeviceEnumerator();
            
            while (EN.Finished == false)
            {
                dv = EN.GetNext();
                if (dv == null)
                {
                    continue;
                }

                if (deviceType.ToLower() != "all")
                {
                    if (deviceTypes.Contains(dv.get_Device_Type_String(hs).ToLower()))
                    {
                        output += "<device name=\"" + dv.get_Name(hs) + "\" id=\"" + dv.get_Ref(hs).ToString() + "\" type=\"" + dv.get_Device_Type_String(hs) + "\" value=\"" + dv.get_devValue(hs).ToString() + "\" address=\"" + dv.get_Address(hs) + "\" code=\"" + dv.get_Code(hs) + "\" canDim=\"" + dv.get_Can_Dim(hs).ToString() + "\" lastChange=\"" + dv.get_Last_Change(hs).ToString() + "\" firstLocation=\"" + dv.get_Location(hs) + "\" secondLocation=\"" + dv.get_Location2(hs) + "\" />";
                    }
                }
                else
                {
                    output += "<device name=\"" + dv.get_Name(hs) + "\" id=\"" + dv.get_Ref(hs).ToString() + "\" type=\"" + dv.get_Device_Type_String(hs) + "\" value=\"" + dv.get_devValue(hs).ToString() + "\" address=\"" + dv.get_Address(hs) + "\" code=\"" + dv.get_Code(hs) + "\" canDim=\"" + dv.get_Can_Dim(hs).ToString() + "\" lastChange=\"" + dv.get_Last_Change(hs).ToString() + "\" firstLocation=\"" + dv.get_Location(hs) + "\" secondLocation=\"" + dv.get_Location2(hs) + "\" />";
                }
            }
        }

        output += "</deviceList>";
        
        return output;
    }



    // Get Devices that match the given locations
    string GetDevicesForLocation(string location1, string location2)
    {
        string output = String.Empty;
        Scheduler.Classes.DeviceClass dv;
        Scheduler.Classes.clsDeviceEnumeration EN = (Scheduler.Classes.clsDeviceEnumeration)hs.GetDeviceEnumerator();

        output = "<deviceListForLocation>";
        
        while (EN.Finished == false)
        {
            dv = EN.GetNext();
            if (dv == null)
            {
                continue;
            }

            if ((dv.get_Location(hs).ToLower() == location1.ToLower()) && (dv.get_Location2(hs).ToLower() == location2.ToLower()))
            {
                output += "<device name=\"" + dv.get_Name(hs) + "\" id=\"" + dv.get_Ref(hs).ToString() + "\" type=\"" + dv.get_Device_Type_String(hs) + "\" value=\"" + dv.get_devValue(hs).ToString() + "\" address=\"" + dv.get_Address(hs) + "\" code=\"" + dv.get_Code(hs) + "\" canDim=\"" + dv.get_Can_Dim(hs).ToString() + "\" lastChange=\"" + dv.get_Last_Change(hs).ToString() + "\" firstLocation=\"" + dv.get_Location(hs) + "\" secondLocation=\"" + dv.get_Location2(hs) + "\" />";
            }
        }

        output += "</deviceListForLocation>";
        
        return output;
    }
    
    
    
    // Get Info for a single device
    string GetDeviceInfo(string deviceName)
    {
        string output = String.Empty;
        Scheduler.Classes.DeviceClass dv;
        Scheduler.Classes.clsDeviceEnumeration EN = (Scheduler.Classes.clsDeviceEnumeration)hs.GetDeviceEnumerator();

        output = "<deviceInfo>";
        
        while (EN.Finished == false)
        {
            dv = EN.GetNext();
            if (dv == null)
            {
                continue;
            }
            
            if (hs.GetDeviceRefByName(deviceName) == dv.get_Ref(hs))
            {
                output += "<device name=\"" + dv.get_Name(hs) + "\" id=\"" + dv.get_Ref(hs).ToString() + "\" type=\"" + dv.get_Device_Type_String(hs) + "\" value=\"" + dv.get_devValue(hs).ToString() + "\" address=\"" + dv.get_Address(hs) + "\" code=\"" + dv.get_Code(hs) + "\" canDim=\"" + dv.get_Can_Dim(hs).ToString() + "\" lastChange=\"" + dv.get_Last_Change(hs).ToString() + "\" firstLocation=\"" + dv.get_Location(hs) + "\" secondLocation=\"" + dv.get_Location2(hs) + "\" />";
                break;
            }
        }

        output += "</deviceInfo>";
        
        return output;
    }



    // Get Info for a single device by ID
    // New in v1.1
    string GetDeviceInfoByID(int deviceRef)
    {
        string output = String.Empty;
        Scheduler.Classes.DeviceClass dv;
        Scheduler.Classes.clsDeviceEnumeration EN = (Scheduler.Classes.clsDeviceEnumeration)hs.GetDeviceEnumerator();

        output = "<deviceInfo>";

        while (EN.Finished == false)
        {
            dv = EN.GetNext();
            if (dv == null)
            {
                continue;
            }

            if (deviceRef == dv.get_Ref(hs))
            {
                output += "<device name=\"" + dv.get_Name(hs) + "\" id=\"" + dv.get_Ref(hs).ToString() + "\" type=\"" + dv.get_Device_Type_String(hs) + "\" value=\"" + dv.get_devValue(hs).ToString() + "\" address=\"" + dv.get_Address(hs) + "\" code=\"" + dv.get_Code(hs) + "\" canDim=\"" + dv.get_Can_Dim(hs).ToString() + "\" lastChange=\"" + dv.get_Last_Change(hs).ToString() + "\" firstLocation=\"" + dv.get_Location(hs) + "\" secondLocation=\"" + dv.get_Location2(hs) + "\" />";
                break;
            }
        }

        output += "</deviceInfo>";

        return output;
    }
    
    
    
    //  Status of device (By Name)
    string DeviceStatusByName(string deviceName, string strDevCmd) 
    {
        int deviceRef = hs.GetDeviceRefByName(deviceName);
        double deviceValue = hs.DeviceValueEx(deviceRef);
        bool IsCAPI_Out = false;
        
        foreach (HomeSeerAPI.CAPI.CAPIControl objCAPIControl in hs.CAPIGetControl(deviceRef))
        {
            if (deviceValue == objCAPIControl.ControlValue) {
                if (objCAPIControl.Label.ToLower() == strDevCmd.ToLower()) {
                    IsCAPI_Out = true;
                }
                break;
            }
        }
        
        return IsCAPI_Out.ToString();
    }

    

    //  Status of device (By ID)
    string DeviceStatusByID(int deviceRef, string strDevCmd)
    {
        double deviceValue = hs.DeviceValueEx(deviceRef);
        bool IsCAPI_Out = false;

        foreach (HomeSeerAPI.CAPI.CAPIControl objCAPIControl in hs.CAPIGetControl(deviceRef))
        {
            if (deviceValue == objCAPIControl.ControlValue)
            {
                if (objCAPIControl.Label.ToLower() == strDevCmd.ToLower())
                {
                    IsCAPI_Out = true;
                }
                break;
            }
        }

        return IsCAPI_Out.ToString();
    }



    //  Gets the Status value of a device (By Name)
    // New in v1.1
    string GetDeviceStatusValueByName(string deviceName, string labelOrValue)
    {
        int deviceRef = hs.GetDeviceRefByName(deviceName);
        double deviceValue = hs.DeviceValueEx(deviceRef);
        string IsCAPI_Out = String.Empty;

        foreach (HomeSeerAPI.CAPI.CAPIControl objCAPIControl in hs.CAPIGetControl(deviceRef))
        {
            if (labelOrValue == "value")
            {
                IsCAPI_Out = deviceValue.ToString();
            }
            else
            {
                if (deviceValue == objCAPIControl.ControlValue)
                {
                    IsCAPI_Out = objCAPIControl.Label.ToLower();
                }
            }
        }

        return IsCAPI_Out.ToString();
    }
    


    //  Gets the Status value of a device (By ID)
    // New in v1.1
    string GetDeviceStatusValueByID(int deviceRef, string labelOrValue)
    {
        double deviceValue = hs.DeviceValueEx(deviceRef);
        string IsCAPI_Out = String.Empty;

        foreach (HomeSeerAPI.CAPI.CAPIControl objCAPIControl in hs.CAPIGetControl(deviceRef))
        {
            if (labelOrValue == "value")
            {
                IsCAPI_Out = deviceValue.ToString();
            }
            else
            {
                if (deviceValue == objCAPIControl.ControlValue)
                {
                    IsCAPI_Out = objCAPIControl.Label.ToLower();
                }
            }
        }

        return IsCAPI_Out.ToString();
    }
    
    
    
    //  Set device (By Name)
    //----------
    // Returns:
    // - Indeterminate
    // - All_Success
    // - Some_Failed
    // - All_Failed
    //----------
    string SetDeviceByName(string deviceName, string strDevCmd)
    {
        int deviceRef = hs.GetDeviceRefByName(deviceName);
        
        HomeSeerAPI.CAPI.CAPIControlResponse CAPIResponse = HomeSeerAPI.CAPI.CAPIControlResponse.Indeterminate;
        foreach (HomeSeerAPI.CAPI.CAPIControl objCAPIControl in hs.CAPIGetControl(deviceRef))
        {
            if (objCAPIControl.Label.ToLower() == strDevCmd.ToLower()) {
                CAPIResponse = hs.CAPIControlHandler(objCAPIControl);
                break;
            }
        }

        return CAPIResponse.ToString();
    }



    //  Set device (By ID)
    //----------
    // Returns:
    // - Indeterminate
    // - All_Success
    // - Some_Failed
    // - All_Failed
    //----------
    string SetDeviceByID(int deviceRef, string strDevCmd)
    {
        HomeSeerAPI.CAPI.CAPIControlResponse CAPIResponse = HomeSeerAPI.CAPI.CAPIControlResponse.Indeterminate;
        foreach (HomeSeerAPI.CAPI.CAPIControl objCAPIControl in hs.CAPIGetControl(deviceRef))
        {
            if (objCAPIControl.Label.ToLower() == strDevCmd.ToLower())
            {
                CAPIResponse = hs.CAPIControlHandler(objCAPIControl);
                break;
            }
        }

        return CAPIResponse.ToString();
    }
</script>
