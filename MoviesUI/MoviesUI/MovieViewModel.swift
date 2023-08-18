

import Foundation

struct MovieViewModel {
    let title: String
    let date: String
    let overview: String
    let imageName: String
}

extension MovieViewModel {
    static var sample: [MovieViewModel] {
        [
            MovieViewModel(
                title: "Spider-Man: Across the Spider-Verse Across the Spider-Verse",
                date: "2023",
                overview: "After reuniting with Gwen Stacy, Brooklyn’s full-time, friendly neighborhood Spider-Man is catapulted across the Multiverse, where he encounters the Spider Society, a team of Spider-People charged with protecting the Multiverse’s very existence. But when the heroes clash on how to handle a new threat, Miles finds himself pitted against the other Spiders and must set out on his own to save those he loves most.",
                imageName: "image0"
            ),
            MovieViewModel(
                title: "Elemental",
                date: "2023",
                overview: "In a city where fire, water, land and air residents live together, a fiery young woman and a go-with-the-flow guy will discover something elemental: how much they have in common.",
                imageName: "image1"
            ),
            MovieViewModel(
                title: "Transformers: Rise of the Beasts",
                date: "2023",
                overview: "When a new threat capable of destroying the entire planet emerges, Optimus Prime and the Autobots must team up with a powerful faction known as the Maximals. With the fate of humanity hanging in the balance, humans Noah and Elena will do whatever it takes to help the Transformers as they engage in the ultimate battle to save Earth.",
                imageName: "image2"
            ),
            MovieViewModel(
                title: "Barbie",
                date: "2023",
                overview: "Barbie and Ken are having the time of their lives in the colorful and seemingly perfect world of Barbie Land. However, when they get a chance to go to the real world, they soon discover the joys and perils of living among humans.",
                imageName: "image3"
            ),
            MovieViewModel(
                title: "Meg 2: The Trench",
                date: "2023",
                overview: "An exploratory dive into the deepest depths of the ocean of a daring research team spirals into chaos when a malevolent mining operation threatens their mission and forces them into a high-stakes battle for survival.",
                imageName: "image4"
            )
        ]
    }
}
