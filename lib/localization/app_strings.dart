
class AppStrings {
  static const Map<String, Map<String, String>> translations = {
    'en': {
      'home': 'Home',
      'subscriptions': 'Subscriptions',
      'upload': 'Upload',
      'you': 'You',
      'search': 'Search',
      'notifications': 'Notifications',
      'signIn': 'Sign In',
      'signUp': 'Sign Up',
      'email': 'Email',
      'password': 'Password',
      'username': 'Username',
      'settings': 'Settings',
      'language': 'Language',
    },
    'es': {
      'home': 'Inicio',
      'subscriptions': 'Suscripciones',
      'upload': 'Subir',
      'you': 'Tú',
      'search': 'Buscar',
      'notifications': 'Notificaciones',
      'signIn': 'Iniciar sesión',
      'signUp': 'Registrarse',
      'email': 'Correo electrónico',
      'password': 'Contraseña',
      'username': 'Nombre de usuario',
      'settings': 'Configuración',
      'language': 'Idioma',
    },
    'fr': {
      'home': 'Accueil',
      'subscriptions': 'Abonnements',
      'upload': 'Télécharger',
      'you': 'Vous',
      'search': 'Rechercher',
      'notifications': 'Notifications',
      'signIn': 'Se connecter',
      'signUp': "S'inscrire",
      'email': 'E-mail',
      'password': 'Mot de passe',
      'username': 'Nom d\'utilisateur',
      'settings': 'Paramètres',
      'language': 'Langue',
    },
  };

  static String translate(String key, {String locale = 'en'}) {
    return translations[locale]?[key] ?? translations['en']?[key] ?? key;
  }
}
