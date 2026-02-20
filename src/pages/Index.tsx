import { Navbar } from "@/components/Navbar";

const Index = () => {
  return (
    <div className="min-h-screen bg-background">
      <Navbar />
      <main className="flex min-h-screen items-center justify-center pt-16">
        <div className="text-center space-y-4">
          <h1 className="text-4xl font-bold tracking-tight text-foreground">
            Bienvenue sur Voltex
          </h1>
          <p className="text-muted-foreground text-lg">
            Votre barre de navigation est prête.
          </p>
        </div>
      </main>
    </div>
  );
};

export default Index;
