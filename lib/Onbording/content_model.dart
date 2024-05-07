class UnbordingContent {
  String image;
  String title;
  String description;

  UnbordingContent({required this.image, required this.title, required this.description});
}

List<UnbordingContent> contents = [
  UnbordingContent(
    title: 'Tender Touch',
    image: 'images/onboarding/Welcome.svg',
    description: "Welcome to our community platform connecting parents of children with special needs with"
        " expert caregivers. Our user-friendly app offers tailored solutions and a supportive environment"
        " for your child's well-being. "
  ),
  UnbordingContent(
    title: 'Unity Hub',
    image: 'images/onboarding/community.svg',
    description: "Join our inclusive community of parents, caregivers, and professionals. "
        "Connect, share experiences, and find support from others who understand your journey."
  ),
  UnbordingContent(
    title: 'Always Active!',
    image: 'images/onboarding/activities.svg',
    description: "Discover personalized activities and instant assistance from our AI chatbot."
        " Empower your child's development with engaging content and expert guidance. "
  ),
];
