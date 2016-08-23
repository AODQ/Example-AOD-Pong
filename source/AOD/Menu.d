/**
  Menu -- Not very useful for many things outside of prototypes. But also
          showcases how you could use AOD. It is only optional however you can
          create your own menu and pass it to AOD.Realm if you so desire

Example:
---
  class Game_Manager {
    Player pl;
  public:
    override void Added_To_AOD() {
      pl = new Player();
      AOD.Add
    }
  }

  void main ( ) {
    Initialize();
    auto m = new AOD.Menu( ... );
    AOD.Add(m);
    AOD.Run();
  }
---
*/
module AODCore.menu;

static import AOD;

/**
  <b>DIAGRAM</b>

  <img src="https://aodq.github.io/files/MENU-base-diagram.png">


<b>BUTTON</b>

---
start    : destroys menu and adds add_on_start to AOD 
controls : Initiates control window                   
credits  : Initiates credits window                   
quit     : Ends program                               
back     : Goes back to main menu                     
---

<b>BUTTON POSITIONING</b> (origin = center of image)

---
start    : button_y * button_y_it*0 
controls : button_y * button_y_it*1 
credits  : button_y * button_y_it*2 
quit     : button_y * button_y_it*3 
back     : <48, 48>                 
---

<b>TEXT</b>

---
general    : font will always be set as def font, origins located at  top-left 
controls   : an array of strings containing each name of control         
credits    : an array of strings containing name and role of team members
---

<b>IMAGE</b>

---
general    : all image origins are the center of the image and use the
              SheetRect structure                   
buttons    : start, controls, credits, quit, back  
background : background, background-submenu        
credits    : array of each member                  
---

<b>BACKGROUND</b>

---
background         : displayed on all menus, should be size of window
background-submenu : displayed on all submenus, after background. Size can
                      vary but it will always be placed at center of window
---

<b>BASE MENU</b>

---
background : Placed at center of window behind all other components
             of the menu
buttons    : start, controls, credits, quit
---


  <img src="https://aodq.github.io/files/MENU-base.png">

<b>CONTROLS MENU</b>

---
button      : back                           
backgrounds : background, background-submenu 
text        : controls                       
---

  <img src="https://aodq.github.io/files/MENU-controls.png">


<b>CREDITS MENU</b>

---
buttons     : back                           
backgrounds : background, background-submenu 
text        : credits                        
image       : credits                        
---
 
  <img src="https://aodq.github.io/files/MENU-credits.png">
*/
class Menu : AOD.Entity {
  AOD.Entity add_on_start;
  immutable( uint ) Button_size = Button.max+1;
  AOD.Entity[Button.max+1] buttons;
  AOD.Entity[] credits;
  AOD.Entity background;
  AOD.Entity background_submenu;
  AOD.Text[] credit_texts,
             controls_text,
             controls_key_text;
public:
  /** */
  enum Button {
    /** */Start,
    /** */Controls,
    /** */Credits,
    /** */Quit,
    /** */Back };
  /** Constructs a new menu
Params:
  img_background         = background image
  img_background_submenu = submenu background image
  img_buttons   = An array of images for the buttons (use Button for index)
  img_credits   = An array of an image of each member (if applicable)
  text_credits  = A name and role of each member (if applicable)
  controls      = An array of strings for each control (see AOD.Input)
  _add_on_start = A reference to an Entity to add to the realm when the menu
                   button "start" has been pressed
  button_y      = Distance from top on y-axis for the first button
  button_y_it   = Distance between each button on the y-axis
  credit_y      = Distance from top of y-axis for each credit slot
  credit_y_it   = Distance between each credit slot on the y-axis
  credit_text_x = Distance from left on x-axis for all credit text
  credit_img_x  = Distance from left on x-axis for all credit images
  */
  this(AOD.SheetRect img_background, AOD.SheetRect img_background_submenu,
       AOD.SheetRect[Button.max+1] img_buttons, AOD.SheetRect[] img_credits,
       string[] text_credits, string[] controls, AOD.Entity _add_on_start,
       int button_y, int button_y_it, int credit_y, int credit_y_it,
       int credit_text_x, int credit_img_x) {
    Set_Visible(0);
    add_on_start = _add_on_start;
    // set up background and buttons
    background = new AOD.Entity(20);
    background.Set_Sprite(img_background, 1);
    background.Set_Position(AOD.R_Window_Width/2, AOD.R_Window_Height/2);
    AOD.Add(background);
    background_submenu = new AOD.Entity(19);
    background_submenu.Set_Sprite(img_background_submenu, 1);
    background_submenu.Set_Size(background_submenu.R_Img_Size());
    background_submenu.Set_Position(AOD.R_Window_Width/2,AOD.R_Window_Height/2);
    background_submenu.Set_Visible(0);
    AOD.Add(background_submenu);
    import std.stdio;
    import std.conv : to;
    writeln("Creating menu");
    writeln("BG POSITION: " ~ cast(string)background.R_Position);
    writeln(to!string(img_background));
    for ( int i = 0; i != Button.max+1; ++ i ) {
      buttons[i] = new AOD.Entity();
      with ( buttons[i] ) {
        Set_Sprite(img_buttons[i], 1);
        import std.conv : to;
        import std.stdio : writeln;
        Set_Size(R_Img_Size);
        Set_Position(AOD.R_Window_Width/2, button_y + (button_y_it * i));
        writeln(cast(string)R_Position);
      }
      AOD.Add(buttons[i]);
    }
    buttons[Button.Back].Set_Position(62, 62);
    buttons[Button.Back].Set_Visible(false);
    
    // set up credits
    for ( int i = 0; i != text_credits.length; ++ i ) {
      auto cy  = credit_y,
           cyi = credit_y_it;
      // text
      /* credit_texts = new AOD.Text(credit_text_x, */
      /*                             cy + cyi*i, text_credits[i]); */
      /* credit_texts.Set_Visible(0); */
      credits ~= new AOD.Entity();
      // img
      with ( credits[$-1] ) {
        Set_Sprite(img_credits[i], 1);
        Set_Position(credit_img_x, cy + cyi/2 + cyi*i);
        Set_Visible(0);
      }
      AOD.Add(credits[$-1]);
    }
    // misc adjustments
    auto w = AOD.R_Window_Width/2, h = AOD.R_Window_Height/2;
  }

  ~this() {
    if ( add_on_start !is null )
      AOD.Add(add_on_start);
    foreach ( b; buttons )
      AOD.Remove(b);
    AOD.Remove(background);
  }

  private void Flip_Menu() {
    foreach ( b; buttons )
      b.Set_Visible(b.R_Visible^1);
    background_submenu.Set_Visible(background_submenu.R_Visible^1);
  }

  // since an entity can be clickeable even though it is not visible
  private bool Clicked(AOD.Entity e) {
    return e.R_Visible && e.Clicked(0);
  }

  private void Set_Controls_Visibility(bool visible) {
    for ( int i = 0; i != controls_text.length; ++ i ) {
      controls_text[i].Set_Visible(visible);
      controls_key_text[i].Set_Visible(visible);
    }
  }

  private void Set_Credits_Visibility(bool visible) {
    foreach ( c; credit_texts )
      c.Set_Visible(false);
  }

  override void Update() {
    if ( Clicked( buttons[Button.Start] ) ) {
      AOD.Remove(this);
      return;
    }
    if ( Clicked( buttons[Button.Credits] ) ) {
      Flip_Menu();
      foreach ( c; credit_texts )
        c.Set_Visible(true);
      return;
    }
    if ( Clicked( buttons[Button.Controls] ) ) {
      Flip_Menu();
      Set_Controls_Visibility(false);
    }
    if ( Clicked( buttons[Button.Back] ) ) {
      Flip_Menu();
    }
  }
}
