methodmap RPJson < JSONObject
{
    // Constructor
    public RPJson() 
    { 
		return view_as<RPJson>(new JSONObject()); 	
    }
};