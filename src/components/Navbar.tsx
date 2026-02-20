import { useState } from "react";
import { Menu, X, Zap } from "lucide-react";
import { Button } from "@/components/ui/button";

const links = [
  { label: "Accueil", href: "#" },
  { label: "Fonctionnalités", href: "#" },
  { label: "Tarifs", href: "#" },
  { label: "À propos", href: "#" },
];

export function Navbar() {
  const [open, setOpen] = useState(false);

  return (
    <header className="navbar-root">
      <div className="navbar-container">
        {/* Logo */}
        <a href="#" className="navbar-logo">
          <Zap className="navbar-logo-icon" />
          <span className="navbar-logo-text">Voltex</span>
        </a>

        {/* Desktop links */}
        <nav className="navbar-links">
          {links.map((link) => (
            <a key={link.label} href={link.href} className="navbar-link">
              {link.label}
            </a>
          ))}
        </nav>

        {/* CTA */}
        <div className="navbar-actions">
          <Button variant="navGhost" size="sm">Connexion</Button>
          <Button variant="navCta" size="sm">Commencer</Button>
        </div>

        {/* Mobile toggle */}
        <button
          className="navbar-toggle"
          onClick={() => setOpen(!open)}
          aria-label="Menu"
        >
          {open ? <X size={22} /> : <Menu size={22} />}
        </button>
      </div>

      {/* Mobile menu */}
      {open && (
        <div className="navbar-mobile">
          {links.map((link) => (
            <a
              key={link.label}
              href={link.href}
              className="navbar-mobile-link"
              onClick={() => setOpen(false)}
            >
              {link.label}
            </a>
          ))}
          <div className="navbar-mobile-actions">
            <Button variant="navGhost" className="w-full">Connexion</Button>
            <Button variant="navCta" className="w-full">Commencer</Button>
          </div>
        </div>
      )}
    </header>
  );
}
