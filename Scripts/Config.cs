using Godot;

namespace Arcomage.Scripts
{
    public class Config : Node
    {
        public enum Tavern
        {
            None,
            Harmondale,
            Erathia,
            TulareanForest,
            Deyja,
            BracadaDesert,
            Celeste,
            ThePit,
            EvermornIsland,
            Nighon,
            BarrowDowns,
            Tidewater,
            Avlee,
            StoneCity
        }
        public enum AiType
        {
            Auto,
            Attack,
            Defence,
            Random
        }
        public enum Locale
        {
            en,
            ru,
            uk,
            pl,
            da
        }
        /// Default game settings
        // Window Settings
        public static bool Fullscreen = false;
        public static bool Borderless = false;
        public static int WindowWidth = 960;
        public static int WindowHeight = 540;
        public static bool Vsync = false;
        public static bool IntroSkip = false;

        // Sound Settings
        public static double MasterVolume = 0.5;
        public static double MusicVolume = 1;
        public static double SoundVolume = 1;
        public static bool MuteSound = false;

        // Starting conditions
        public static bool Singleplayer = true;
        public static bool SingleClick = true;
        public static int TowerLevels = 50;
        public static int WallLevels = 50;
        public static int QuarryLevels = 5;
        public static int BrickQuantity = 20;
        public static int MagicLevels = 3;
        public static int GemQuantity = 10;
        public static int DungeonLevels = 5;
        public static int RecruitQuantity = 20;

        // Play conditions
        public static int AutoBricks = 0;
        public static int AutoGems = 0;
        public static int AutoRecruits = 0;
        public static int CardsInHand = 6;
        public static AiType CurrentAiType = AiType.Auto;
    

        // Victory conditions
        public static int TowerVictory = 100;
        public static int ResourceVictory = 300;

        // Tavern presets
        public static Tavern CurrentTavern = Tavern.None;

        // Language settings
        public static Locale CurrentLocale = Locale.en;

        // Player settings
        public static string Nickname = "Player";
    }
}
